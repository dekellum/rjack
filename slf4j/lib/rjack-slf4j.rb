#--
# Copyright (c) 2008-2016 David Kellum
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++

require 'rjack-slf4j/base'
require 'java'

module RJack

  # Wrapper and core Logger compatible adapter for the
  # SLF4J[http://www.slf4j.org/] logging interface.
  #
  # == Usage
  #
  #   require 'rjack-slf4j'
  #
  #   log = RJack::SLF4J[ "my.app.logger" ]
  #   log.info "Hello World!"
  #
  # == Adapters
  #
  # An output adapter must be required before the first log call.  All
  # of the following output adapters are available via +require+ from
  # the slf4j gem:
  #
  #   require 'rjack-slf4j/jcl'       # Output to Jakarta Commons Logging
  #   require 'rjack-slf4j/jdk14'     # JDK java.util.logging (JUL)
  #   require 'rjack-slf4j/log4j12'   # Log4j (provided elsewhere)
  #   require 'rjack-slf4j/nop'       # NOP null logger (provided)
  #   require 'rjack-slf4j/simple'    # Simple logger (provided)
  #
  # The rjack-logback[http://rjack.gravitext.com/logback] gem may
  # also be be used as the output adapter:
  #
  #   require 'rjack-logback'
  #
  # The first loaded output adapter wins (as with multiple adapters on
  # the classpath). A warning will be logged to "slf4j" if an attempt is
  # made to require a second output adapter.
  #
  # The following input adapters will intercept JCL, java.util.logging
  # (JUL), or log4j log output and direct it through SLF4J:
  #
  #   require 'rjack-slf4j/jcl-over-slf4j'   # Route Jakarta Commons Logging to SLF4J
  #   require 'rjack-slf4j/log4j-over-slf4j' # Log4j to SLF4J
  #
  #   require 'rjack-slf4j/jul-to-slf4j'     # JDK java.util.logging (JUL) to SLF4J
  #   RJack::SLF4J::JUL.replace_root_handlers # Special case setup for JUL
  #
  # Multiple input adapters may be require'd.  However, a RuntimeError
  # will be raised in the attempt to require both an output adapter and
  # input adapter from/to the same interface, for example
  # 'rjack-slf4j/jcl-over-slf4j' and 'rjack-slf4j/jcl', which would otherwise cause
  # a circular logging loop (and stack overflow.)
  #
  # Adapter names match the corresponding SLF4J jars.
  #
  module SLF4J

    # Require an adapter by name (add the jar to classpath)
    # This is normally done via require 'slf4j/_name_'
    def self.require_adapter( name )
      row = ADAPTERS.assoc( name )
      if row
        name,ban = row
        output = false
      else
        row = ADAPTERS.rassoc( name )
        ban,name = row
        output = true
      end

      if @@loaded[ ban ]
        raise "Illegal attempt to load '#{name}' when '#{ban}' is loaded."
      end

      if output
        if ! @@output_name.nil? && name != @@output_name
          logger("slf4j").warn do
            "Ignoring attempt to load #{name} after #{@@output_name} already loaded."
          end
          return
        end
        if java.lang.Thread::current_thread.context_class_loader != @@api_loader
          $stderr.puts( "WARNING: Attempting to load #{name} in child class" +
                        " loader of slf4j-api.jar loader." )
        end
        require_jar( 'slf4j-' + name )
        @@output_name = name
      else
        require_jar( name )
      end

      @@loaded[ name ] = true
    end

    def self.require_jar( name ) # :nodoc:
      require File.join( SLF4J_DIR, "#{name}-#{ SLF4J_VERSION }.jar" )
    end

    require_jar 'slf4j-api'

    @@api_loader = org.slf4j.ILoggerFactory.java_class.class_loader
    @@loaded = {}
    @@output_name = nil
    @@ruby_ex_format = "%s %s: %s\n".freeze

    # Output adapter name if one has been added, or nil.
    def self.output_name
      @@output_name
    end

    # A (sprintf) format string to use when synthesizing a log message
    # from a prefix message (msg) (i.e. "Exception:") and ruby
    # exception (ex) using [ msg, ex.class.name, ex.cause ]. Since
    # ruby exceptions aren't instances of java Throwable, they can't
    # be passed directly. This can be globally set to match the
    # formatting of the output adapter (i.e. for java exceptions),
    # preferably in the same place it is required and configured.
    def self.ruby_ex_format
      @@ruby_ex_format
    end

    def self.ruby_ex_format=( f )
      @@ruby_ex_format = f.dup.freeze
    end

    # SLF4J severity levels
    LEVELS = %w{ trace debug info warn error }

    # Return a java style class name, suitable as a logger name, from the
    # given ruby class or module, i.e:
    #
    #    to_log_name( Foo::Bar::Baz ) --> "foo.bar.Baz"
    #
    def self.to_log_name( clz )
      clz.name.gsub( /::/, '.' ).gsub( /([^\.]+)\./ ) { |m| m.downcase }
    end

    class << self
      alias ruby_to_java_logger_name to_log_name
    end

    # Ruby ::Logger compatible adapter for org.slf4j.Logger
    #
    # === Generated Methods
    #
    # Corresponding methods are generated for each of the SLF4J levels:
    #
    # * trace
    # * debug
    # * info
    # * warn
    # * error
    # * fatal (alias to error)
    #
    # These have the form (using _info_ as example):
    #
    #   log = Logger.new( "name" )
    #   log.info?                    # Is this level enabled for logging?
    #   log.info( "message" )        # Log message
    #   log.info { "message" }       # Execute block if enabled
    #                                  and log returned value
    #   log.info( "message", ex )    # Log message with exception message/stack trace
    #   log.info( ex ) { "message" } # Log message with exception message/stack trace
    #   log.info( ex )               # Log exception with default "Exception:" message
    #
    # Note that the exception variants are aware of JRuby's
    # NativeException class (a wrapped java exception) and will log
    # using the Java ex.cause in this case.
    #
    class Logger
      attr_reader :name

      # Create new or find existing Logger by name. If name is a Module (Class, etc.)
      # then use SLF4J.to_log_name( name ) as the name
      #
      # Note that loggers are arranged in a hiearchy by dot '.' name
      # notation using java package/class name conventions:
      #
      # * "pmodule"
      # * "pmodule.cmodule."
      # * "pmodule.cmodule.ClassName"
      #
      # Which enables hierarchical level setting and abbreviation in some output adapters.
      #
      def initialize( name )
        @name = name.is_a?( Module ) ? SLF4J.to_log_name( name ) : name
        @logger = org.slf4j.LoggerFactory.getLogger( @name )
        @level = 0 #DEBUG
      end

      # Return underlying org.slf4j.Logger
      def java_logger
        @logger
      end

      # Define logging methods for each level: debug(), error(), etc.
      LEVELS.each do |lvl|
        module_eval( %Q{

          def #{lvl}?
            @logger.is#{lvl.capitalize}Enabled
          end

          def #{lvl}( msg=nil, ex=nil )
            if ex.nil? && ( msg.is_a?( Exception ) ||
                            msg.is_a?( java.lang.Throwable ) )
              msg, ex = "Exception:", msg
            end
            msg = yield if ( block_given? && #{lvl}? )
            if msg
              if ex
                #{lvl}_ex( msg, ex )
              else
                @logger.#{lvl}( msg.to_s )
              end
            end
            true
          end

          def #{lvl}_ex( msg, ex )
            if ex.is_a?( java.lang.Throwable )
              @logger.#{lvl}( msg.to_s, ex )
            elsif ex.is_a?( NativeException )
              @logger.#{lvl}( msg.to_s, ex.cause )
            elsif #{lvl}?
              lm = sprintf( SLF4J.ruby_ex_format,
                            msg, ex.class.name, ex.message )
              ex.backtrace && ex.backtrace.each do |b|
                lm << '\t' << b << '\n'
              end
              @logger.#{lvl}( lm )
            end
            true
          end

        } )
      end

      # Unused attribute, for Ruby ::Logger compatibility.
      attr_reader :progname

      # Unused attribute, for Ruby ::Logger compatibility.
      def progname=( v )
        debug { "Setting SLF4J::Logger progname=#{v.inspect} has no effect" }
        @progname = v
      end

      # Unused attribute, for Ruby ::Logger compatibility.
      attr_reader :level

      # Unused attribute, for Ruby ::Logger compatibility.
      def level=( v )
        debug { "Setting SLF4J::Logger level=#{v.inspect} has no effect" }
        @level = v
      end

      # Unused attribute alias, for Ruby ::Logger compatibility.
      alias sev_threshold  level
      alias sev_threshold= level=

      # Unused attribute, for Ruby ::Logger compatibility.
      attr_reader :datetime_format

      # Unused attribute, for Ruby ::Logger compatibility.
      def datetime_format=( v )
        debug { "Setting SLF4J::Logger datetime_format=#{v.inspect} has no effect" }
        @datetime_format = v
      end

      # Unused attribute, for Ruby ::Logger compatibility.
      attr_reader :formatter

      # Unused attribute, for Ruby ::Logger compatibility.
      def formatter=( v )
        debug { "Setting SLF4J::Logger formatter=#{v.inspect} has no effect" }
        @formatter = v
      end

      # Alias to #error for Ruby ::Logger compatibility
      alias fatal  error
      alias fatal? error?

      # Alias to #info for Ruby ::Logger compatibility. Extend to map to
      # a different level.
      alias << info

      # Alias to #info for Ruby ::Logger compatibility. Extend to map to
      # a different level.
      alias unknown info

      # Log via Ruby ::Logger levels, for compatibility.
      # UNKNOWN or nil level is mapped to #info
      def add( rlvl, msg = nil, progname = nil, &block )
        case rlvl
        when 0 #DEBUG
          debug( msg, &block )
        when 1 #INFO
          info( msg, &block )
        when 2 #WARN
          warn( msg, &block )
        when 3 #ERROR
          error( msg, &block )
        when 4 #FATAL
          error( msg, &block )
        else #UNKNOWN, nil
          info( msg, &block )
        end
      end

      alias log add

      # No-Op, for Ruby ::Logger compatibility.
      def close
        #No-OP
      end

    end

    # Get Logger by name
    def logger( name = self.class.name )
      Logger.new( name )
    end
    module_function :logger

    # Synonym for Logger.new( name )
    def self.[]( name )
      Logger.new( name )
    end

    # The ILoggerFactory instance if an output adapter has been loaded
    def self.linked_factory
       org.slf4j.LoggerFactory.getILoggerFactory
    end

  end
end
