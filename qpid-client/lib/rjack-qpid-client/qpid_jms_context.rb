#--
# Copyright (c) 2011-2012 David Kellum
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#++

require 'rjack-qpid-client'
require 'socket'
require 'rjack-slf4j'
require 'rjack-jms'

module RJack::QpidClient

  # Implementation of RJack::JMS::JMSContext for Qpid, using the
  # {Qpid JNDI Properties}[http://qpid.apache.org/books/0.8/Programming-In-Apache-Qpid/html/ch03s02.html]
  # syntax. Provides scripted setup and a factory for JMS Connection,
  # Session, and Destinations (including full AMQP queue and exchange
  # creation) via Qpid
  # {Addresses}[http://qpid.apache.org/books/0.8/Programming-In-Apache-Qpid/html/ch02s04.html]
  # created from ruby.
  class QpidJMSContext
    include RJack::JMS::JMSContext

    import 'javax.naming.Context'
    import 'javax.naming.InitialContext'
    import 'javax.jms.Session'

    # User to connect with (required, often unused by broker,
    # default: 'qpid')
    attr_accessor :username

    # Password to connect with (required, often unused by broker.)
    attr_accessor :password

    # Array of [ host[,port] ] arrays to brokers (default: [['localhost']] )
    # Default port is 5672.
    attr_accessor :brokers

    # Connection 'virtualhost' (default: 'default-vhost')
    # See JNDI Properties, 3.2.2 Connection URLs
    attr_accessor :virtual_host

    # Connection 'clientid' (default: 'default-client')
    # See JNDI Properties, 3.2.2 Connection URLs
    attr_accessor :client_id

    # Connection factory, JNDI name (default: 'local')
    attr_accessor :factory_jndi_name

    # Acknowledge Mode specified on create_session
    # (default: javax.jms.Session::AUTO_ACKNOWLEDGE).
    attr_accessor :session_acknowledge_mode

    # Hash of destination JNDI name to an 'address; options' Hash.
    # The option hash may use ruby Symbol or String keys, and
    # true, false, Symbol, String, Hash, or Array values. This will be
    # serialized into the Qpid
    # {Addresses}[http://qpid.apache.org/books/0.8/Programming-In-Apache-Qpid/html/ch02s04.html]
    # Syntax. The special keys :address (default: same as JNDI name)
    # and :subject (optional address/subject) are also supported when
    # serializing. (Default: empty)
    attr_accessor :destinations

    def initialize
      @username = 'qpid'
      @password = 'pswd'
      @brokers = [ [ 'localhost' ] ]

      @virtual_host = 'default-vhost'
      @client_id    = 'default-client'

      @factory_jndi_name = 'local'

      @session_acknowledge_mode = Session::AUTO_ACKNOWLEDGE
      @destinations = {}
      @log = RJack::SLF4J[ self.class ]
    end

    # The JNDI InitialContext, created on first call, from properties.
    def context
      @context ||= InitialContext.new( properties )
    end

    # The javax.jms.ConnectionFactory, created on first call, by lookup
    # of factory_jndi_name from context.
    #
    # Throws javax.naming.NamingException
    def connection_factory
      @con_factory ||= context.lookup( factory_jndi_name )
    end

    # Creates a new
    # {javax.jms.Connection}[http://download.oracle.com/javaee/5/api/javax/jms/Connection.html]
    # from the connection_factory. Caller should close this connection when done with it.
    #
    # Throws javax.jms.JMSException, javax.naming.NamingException
    def create_connection
      connection_factory.create_connection
    rescue NativeException => x
      raise x.cause
    end

    # Create a
    # {javax.jms.Session}[http://download.oracle.com/javaee/5/api/javax/jms/Session.html]
    # from the connection previously obtained via create_connection.
    #
    # Throws javax.jms.JMSException
    def create_session( connection )
      connection.create_session( false, session_acknowledge_mode )
    rescue NativeException => x
      raise x.cause
    end

    # Lookup (and thus create) a
    # {javax.jms.Destination}[http://download.oracle.com/javaee/5/api/javax/jms/Destination.html]
    # by JNDI name as key into destination.  The name and full address
    # specification is logged at this point.
    #
    # Throws javax.naming.NamingException
    def lookup_destination( name )
      @log.info( "Lookup of destinations[ '%s' ] =\n    %s" %
                 [ name,
                   address_serialize( name, @destinations[ name ] ) ] )
      context.lookup( name )
    rescue NativeException => x
      raise x.cause
    end

    # Close the JNDI context (no more lookups may be made.)
    def close
      @con_factory = nil

      @context.close if @context
      @context = nil
    end

    # Qpid JNDI Properties including connection_url and destinations.
    def properties
      props = Java::java.util.Hashtable.new

      props[ Context::INITIAL_CONTEXT_FACTORY ] =
        "org.apache.qpid.jndi.PropertiesFileInitialContextFactory"

      props[ [ "connectionfactory", factory_jndi_name ].join( '.' ) ] =
        connection_url

      destinations.each_pair do |name,opts|
        props[ [ "destination", name ].join( '.' ) ] =
          address_serialize( name, opts )
      end

      props
    end

    # Serialize destination
    # {Addresses}[http://qpid.apache.org/books/0.8/Programming-In-Apache-Qpid/html/ch02s04.html]
    # (new format). Reference: section 2.4.3.5
    def address_serialize( name, opts = nil )
      opts = opts.dup
      out = ( opts.delete( :address ) || name ).to_s
      subject = opts.delete( :subject )
      out += '/' + subject.to_s if subject
      out += '; ' + option_serialize( opts ) if opts
      out
    end

    # Serialize addresses options Hash
    def option_serialize( val )
      case( val )
      when TrueClass, FalseClass, Symbol, Integer
        val.to_s
      when String
        val.to_s.inspect #quote/escape
      when Hash
        pairs = val.map do | key, value |
          [ wrap_key( key ), option_serialize( value ) ].join( ": " )
        end
        '{ ' + pairs.join( ', ' ) + ' }'
      when Array
        values = val.map do | value |
          option_serialize( value )
        end
        '[ ' + values.join( ', ' ) + ' ]'
      else
        raise "Unknown option value class: " + val.class.to_s
      end
    end

    # Quote keys that require it based on Qpid address scheme (most
    # commonly, those with '.' in them).
    def wrap_key( key )
      k = key.to_s
      if ( k =~ /^[a-zA-Z_][a-zA-Z0-9_-]*[a-zA-Z0-9_]$/ )
        k
      else
        "'" + k + "'"
      end
    end

    # The AMQP specific Connection URL as defined in Qpid JNDI
    # Properities.
    def connection_url
      url = "amqp://"

      if username
        url += username
        url += ':' + password if password
        url += '@'
      end

      url += [ client_id, virtual_host ].join( '/' )

      url += '?'

      url += "brokerlist='#{ broker_list }'"

      url
    end

    # Broker list Connection URL parameter value from input brokers.
    def broker_list
      l = brokers.map do | host, port |
        'tcp://%s:%s' % [ host, port || 5672 ]
      end

      l.join( ';' )
    end

    # Appends Socket.gethostname and the current Process.pid to the
    # specified prefix to create a (transient) unique address name
    def address_per_process( prefix )
      [ prefix,
        Socket.gethostname.to_s.split( '.' ).first,
        Process.pid.to_s ].compact.join( '-' )
    end

  end
end
