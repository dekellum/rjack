#--
# Copyright (c) 2008-2015 David Kellum
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You
# may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#++

require 'uri'
require 'rjack-jetty/base'

require 'java'

module RJack

  # {Jetty Web Server}[http://www.mortbay.org/jetty/] module including
  # a ServerFactory
  module Jetty

    def self.require_jar( name )
      require File.join( JETTY_DIR, "#{name}-#{ JETTY_VERSION }.#{ JETTY_BUILD }.jar" )
    end

    require_jar 'jetty-io'
    require_jar 'jetty-http'
    require_jar 'jetty-continuation'
    require_jar 'jetty-server'
    require_jar 'jetty-security'
    require_jar 'jetty-servlet'
    require_jar 'jetty-xml'
    require_jar 'jetty-webapp'
    require_jar 'jetty-util'

    require File.join( JETTY_DIR, "javax.servlet-api-#{ SERVLET_API_VERSION }.jar" )

    import 'org.eclipse.jetty.http.HttpVersion'
    import 'org.eclipse.jetty.server.Connector'
    import 'org.eclipse.jetty.server.Handler'
    import 'org.eclipse.jetty.server.HttpConfiguration'
    import 'org.eclipse.jetty.server.NCSARequestLog'
    import 'org.eclipse.jetty.server.SecureRequestCustomizer'
    import 'org.eclipse.jetty.server.Server'
    import 'org.eclipse.jetty.server.SslConnectionFactory'
    import 'org.eclipse.jetty.server.handler.AbstractHandler'
    import 'org.eclipse.jetty.server.handler.ContextHandler'
    import 'org.eclipse.jetty.server.handler.ContextHandlerCollection'
    import 'org.eclipse.jetty.server.handler.DefaultHandler'
    import 'org.eclipse.jetty.server.handler.HandlerCollection'
    import 'org.eclipse.jetty.server.handler.RequestLogHandler'
    import 'org.eclipse.jetty.server.handler.ResourceHandler'
    import 'org.eclipse.jetty.server.HttpConnectionFactory'
    import 'org.eclipse.jetty.server.ServerConnector'
    import 'org.eclipse.jetty.servlet.ServletContextHandler'
    import 'org.eclipse.jetty.servlet.ServletHolder'
    import 'org.eclipse.jetty.webapp.WebAppContext'
    import 'org.eclipse.jetty.util.ssl.SslContextFactory'
    import 'org.eclipse.jetty.util.thread.QueuedThreadPool'

    # A factory for creating complete org.morbay.jetty.Server
    # instances. Provides a general purpose facade for setup including
    # the Server, a ThreadPool, a Connector, and various Handlers.  It
    # is non-exhaustive (not every Jetty facility is provided) but is
    # designed to be easily extended.
    #
    # == Example
    #
    #   factory = Jetty::ServerFactory.new
    #   factory.max_threads = 20
    #   factory.port = 8080
    #
    #   # Set static resource context mapping URI to directory
    #   factory.static_contexts[ '/html' ] = '/var/www/html'
    #
    #   # Implement custom handler and register it.
    #   import 'org.eclipse.jetty.handler.AbstractHandler'
    #   class RedirectHandler < AbstractHandler
    #
    #     def initialize( redirects )
    #       super()
    #       @redirects = redirects
    #     end
    #
    #     def handle( target, base_request, request, response )
    #       goto = @redirects[ target ]
    #       unless goto.nil?
    #         response.send_redirect( goto )
    #         base_request.handled = true
    #       end
    #     end
    #   end
    #
    #   def factory.create_pre_handlers
    #     [ RedirectHandler.new( '/' => '/html/' ) ] + super
    #   end
    #
    #   # Create a webapp context (war file or webapp expanded)
    #   factory.webapp_contexts[ '/test' ] = Jetty::TestServlets::WEBAPP_TEST_WAR
    #
    #   # Create a context for a custom HelloServlet
    #   import 'javax.servlet.http.HttpServlet'
    #   class HelloServlet < HttpServlet
    #     def doGet( request, response )
    #       response.content_type = "text/plain"
    #       response.writer.write( 'Hello World!' )
    #     end
    #   end
    #
    #   factory.set_context_servlets( '/hello', { '/*' => HelloServlet.new } )
    #
    #   # Create, start, and join (wait for shutdown)
    #   server = factory.create
    #   server.start
    #   server.join
    #
    class ServerFactory

      # Default port number or 0 to use any available port, for a
      # single connection. Default: 0
      # Deprecated: use #connections instead.
      attr_accessor :port

      # Default idle time in milliseconds to use for all connections.
      # Default: 10,000 ms
      attr_accessor :max_idle_time_ms

      # Maximum number of threads. A minimum value of 7 is used, based
      # on the testing with the current Jetty version. Default: 20
      attr_accessor :max_threads

      # Minimum number of threads. A minimum value of 4 is
      # used. Default: max_threads / 4
      attr_accessor :min_threads

      # Hash of request path prefixes to local file systems paths for
      # static content. Default: {}
      attr_accessor :static_contexts

      # Array of welcome file names. Default: [ 'index.html' ]
      attr_accessor :static_welcome_files

      # Hash of request path prefexes to java webapp paths
      # Default: {} (none)
      attr_accessor :webapp_contexts

      # Hash of request path prefexes to servlet paths. Default: {}
      attr_accessor :servlet_contexts

      # Explicitly and gracefully stop the server on shutdown?
      # Default: true
      attr_accessor :stop_at_shutdown

      # Request log output to :stderr or file name (default: nil, no log)
      attr_accessor  :request_log_file

      # An array of connection options, each member being a hash with
      # the following properties or an equivalent URI string:
      #
      # :scheme:: Values 'tcp' or 'ssl'
      # :host:: The local interface to bind Default: 0.0.0.0 (all)
      # :port:: Port number or 0 to select an available port
      #         (Default: top level #port for first connection, 0 )
      # :max_idle_time_ms:: See above
      # :key_store_path:: For ssl, the path to the (Java JKS) keystore
      # :key_store_password:: For ssl, the password to the keystore
      #
      # URI examples:
      #
      #  tcp://127.0.0.1
      #  ssl://0.0.0.0:8443?key_store_path=test/keystore&key_store_password=399as8d9
      #
      attr_accessor  :connections

      def initialize
        @port                 = 0        # Use any available port
        @max_threads          = 20
        @min_threads          = nil      # Compute from max_threads
        @max_idle_time_ms     = 10000
        @static_contexts      = {}
        @static_welcome_files = [ 'index.html' ]
        @webapp_contexts      = {}
        @request_log_file     = nil
        @servlet_contexts     = {}
        @stop_at_shutdown     = true
        @connections          = nil
      end

      # Returns a new org.morbay.jetty.Server that is ready to
      # be started.
      def create
        server = Server.new( create_pool )

        server.connectors = create_connectors( server )

        hcol = HandlerCollection.new
        hcol.handlers = create_handlers.compact
        server.handler = hcol

        server.stop_at_shutdown = @stop_at_shutdown

        server
      end

      # Return a org.eclipse.thread.ThreadPool implementation.
      #
      # This implementation creates a QueuedThreadPool with
      # min_threads (default max_threads / 4), and max_threads
      # (default 20).
      def create_pool
        pool = QueuedThreadPool.new
        pool.min_threads = [ @min_threads || ( @max_threads / 4 ), 4 ].max
        pool.max_threads = [ @max_threads, 7 ].max
        pool
      end

      # Return array of org.eclipse.jetty.Connector instances.
      def create_connectors( server )
        first = true
        ( connections || [{ scheme: 'tcp' }] ).map do |opts|
          opts = parse_connection_uri( opts ) if opts.is_a?( String )

          connector = case opts[:scheme]
                      when 'ssl'
                        create_https_connector( server, opts )
                      when 'tcp'
                        create_http_connector( server, opts )
                      else
                        raise "Unsupported connection scheme '#{opts[:scheme]}'"
                      end
          connector.host = opts[:host] if opts[:host]
          connector.port = opts[:port] || ( first && @port ) || 0
          connector.idle_timeout = opts[:max_idle_time_ms] || @max_idle_time_ms
          first = false
          connector
        end
      end

      def parse_connection_uri( uri )
        u = URI.parse( uri )
        opts = { scheme: u.scheme,
                 host: u.host,
                 port: u.port }

        if u.query
          params = URI.decode_www_form( u.query )
          params = params.inject({}) { |m,(k,v)| m[k.to_sym] = v; m }
          opts.merge!( params )
        end

        opts
      end
      def create_http_connector( server, opts = {} )
        ServerConnector.new( server )
      end

      def create_https_connector( server, opts = {} )
        ctx_f = SslContextFactory.new
        if opts[:key_store_path]
          ctx_f.key_store_path = opts[:key_store_path]
        end
        if opts[:key_store_password]
          ctx_f.key_store_password = opts[:key_store_password]
        end
        ssl_con_f = SslConnectionFactory.new(ctx_f, HttpVersion::HTTP_1_1.to_s)

        conf = HttpConfiguration.new
        conf.add_customizer( SecureRequestCustomizer.new )
        http_con_f = HttpConnectionFactory.new( conf )

        ServerConnector.new( server, ssl_con_f, http_con_f )

      end

      # Returns an Array of org.eclipse.jetty.Handler instances.
      #
      # This implementation concatenates create_pre_handlers and
      # create_post_handlers.
      def create_handlers
        ( create_pre_handlers + create_post_handlers )
      end

      # Returns an Array of "pre" org.eclipse.jetty.Handler instances.
      #
      # This implementation returns an array containing a single
      # ContextHandlerCollection which itself contains the context
      # handlers set by create_context_handlers, or an empty array
      # if no context handlers were set.
      def create_pre_handlers
        ctx_handlers = ContextHandlerCollection.new
        create_context_handlers( ctx_handlers )
        h = ctx_handlers.handlers
        if( h.nil? || h.length == 0 )
          [ ]
        else
          [ ctx_handlers ]
        end
      end

      # Returns an Array of "post" org.eclipse.jetty.Handler instances.
      #
      # This implementation returns a DefaultHandler instance, and any
      # handler returned by create_request_log_handler.
      def create_post_handlers
        [ DefaultHandler.new, # Handle errors, etc.
          create_request_log_handler ]
      end

      # Create context handlers on the provided ContextHandlerCollection
      #
      # This implementation calls create_static_contexts,
      # create_webapp_contexts, and create_servlet_context.
      def create_context_handlers( context_handler_collection )
        create_static_contexts( context_handler_collection )
        create_webapp_contexts( context_handler_collection )
        create_servlet_contexts( context_handler_collection )
      end

      # Create context handlers for static resources from static_contexts
      def create_static_contexts( context_handler_collection )
        @static_contexts.each do |ctx, rpath|
          ch = ContextHandler.new( context_handler_collection, ctx )
          ch.resource_base = rpath
          ch.handler = ResourceHandler.new
          ch.handler.welcome_files = @static_welcome_files
        end
      end

      # Set a context of servlets given context_path, a servlets hash
      # (mapping path to Servlet), and options.
      def set_context_servlets( context_path, servlets,
                                options = ServletContextHandler::NO_SESSIONS )
        @servlet_contexts[ context_path ] = [ servlets, options ]
      end

      # Create context handlers from servlet_contexts.
      def create_servlet_contexts( context_handler_collection )
        @servlet_contexts.each do |ctx, s_o|
          servlets, options = s_o
          context = ServletContextHandler.new( context_handler_collection, ctx, options )
          servlets.each do |path, servlet|
            context.add_servlet( ServletHolder.new( servlet ), path )
          end
        end
      end

      # Create webapp context handlers from webapp_contexts.
      def create_webapp_contexts( context_handler_collection )
        @webapp_contexts.each do |ctx, webapp_path|
          WebAppContext.new( context_handler_collection, webapp_path, ctx )
        end
      end

      # Create RequestLogHandler from any set request_log_file
      def create_request_log_handler
        if @request_log_file
          log_handler = RequestLogHandler.new
          log_handler.request_log = create_request_log( @request_log_file )
          log_handler
        end
      end

      # Create a NCSARequestLog to append to log_file
      def create_request_log( log_file )
        log = if log_file == :stderr
                NCSARequestLog.new
              else
                NCSARequestLog.new( log_file )
              end
        log.log_time_zone = java.util.TimeZone::getDefault.getID
        log.append = true;
        log
      end

    end
  end
end
