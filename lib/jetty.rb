#--
# Copyright (C) 2008 David Kellum
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

require 'jetty/base'

# {Jetty Web Server}[http://www.mortbay.org/jetty/] module including
# a ServerFactory
module Jetty
  include JettyBase

  def self.require_jar( name )
    require File.join( JETTY_DIR, "#{name}-#{ JETTY_VERSION }.jar" )
  end

  require_jar 'jetty'
  require_jar 'jetty-util'
  require_jar "servlet-api-#{ SERVLET_API_VERSION }"

  import 'org.mortbay.jetty.Connector'
  import 'org.mortbay.jetty.Handler'
  import 'org.mortbay.jetty.NCSARequestLog'
  import 'org.mortbay.jetty.Server'
  import 'org.mortbay.jetty.handler.ContextHandler'
  import 'org.mortbay.jetty.handler.ContextHandlerCollection'
  import 'org.mortbay.jetty.handler.DefaultHandler'
  import 'org.mortbay.jetty.handler.HandlerCollection'
  import 'org.mortbay.jetty.handler.RequestLogHandler'
  import 'org.mortbay.jetty.handler.ResourceHandler'
  import 'org.mortbay.jetty.nio.SelectChannelConnector'
  import 'org.mortbay.jetty.servlet.Context'
  import 'org.mortbay.jetty.servlet.ServletHolder'
  import 'org.mortbay.jetty.webapp.WebAppContext'
  import 'org.mortbay.thread.QueuedThreadPool'
  
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
  #   import 'org.mortbay.jetty.handler.AbstractHandler'
  #   class RedirectHandler < AbstractHandler
  #
  #     def initialize( redirects )
  #       super()
  #       @redirects = redirects
  #     end
  #
  #     def handle( target, request, response, dispatch )
  #       goto = @redirects[ target ]
  #       unless goto.nil?
  #         response.send_redirect( goto ) 
  #         request.handled = true
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
    attr_accessor( :port, :max_idle_time_ms,
                   :max_threads, :low_threads, :min_threads,
                   :static_contexts, :static_welcome_files,
                   :webapp_contexts,
                   :servlet_contexts,
                   :stop_at_shutdown,
                   :request_log_file )

    def initialize
      @port                 = 0        # Use any available port
      @max_threads          = 20  
      @low_threads          = 0        # No low thread threshold
      @min_threads          = nil      # Compute from max_threads
      @max_idle_time_ms     = 10000    
      @static_contexts      = {}
      @static_welcome_files = [ 'index.html' ]
      @webapp_contexts      = {}
      @request_log_file     = nil
      @servlet_contexts     = {}
      @stop_at_shutdown     = true
    end
    
    # Returns a new org.morbay.jetty.Server that is ready to
    # be started.
    def create
      server = Server.new

      server.thread_pool = create_pool

      server.connectors = create_connectors.to_java( Connector )

      hcol = HandlerCollection.new
      hcol.handlers = create_handlers.compact.to_java( Handler )
      server.handler = hcol
      
      server.stop_at_shutdown = @stop_at_shutdown

      server
    end
    
    # Return a org.mortbay.thread.ThreadPool implementation.  
    #
    # This implementation creates a QueuedThreadPool with min_threads
    # (default max_threads / 4), any low_threads, and max_threads
    # (default 20).
    def create_pool
      pool = QueuedThreadPool.new
      pool.min_threads = [ @min_threads || ( @max_threads / 4 ), 1 ].max
      pool.low_threads = @low_threads
      pool.max_threads = [ @max_threads, 2 ].max
      pool
    end

    # Return array of org.mortbay.jetty.Connector instances.
    #
    # This implementation returns a single SelectChannelConnector
    # listening to the given port or an auto-selected avaiable
    # port. Connections are retained for max_idle_time_ms.
    def create_connectors
      connector = SelectChannelConnector.new
      connector.port = @port
      connector.max_idle_time = @max_idle_time_ms
      [ connector ]
    end

    # Returns an Array of org.mortbay.jetty.Handler instances.
    # 
    # This implementation concatenates create_pre_handlers and
    # create_post_handlers.
    def create_handlers
      ( create_pre_handlers + create_post_handlers )
    end

    # Returns an Array of "pre" org.mortbay.jetty.Handler instances.
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

    # Returns an Array of "post" org.mortbay.jetty.Handler instances.
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
        ch.handler.welcome_files = 
          @static_welcome_files.to_java( java.lang.String )
      end
    end

    # Set a context of servlets given context_path, a servlets hash
    # (mapping path to Servlet), and options.
    def set_context_servlets( context_path, servlets, 
                              options = Context::NO_SESSIONS )
      @servlet_contexts[ context_path ] = [ servlets, options ]
    end

    # Create context handlers from servlet_contexts.
    def create_servlet_contexts( context_handler_collection )
      @servlet_contexts.each do |ctx, s_o|
        servlets, options = s_o
        context = Context.new( context_handler_collection, ctx, options )
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
      log = NCSARequestLog.new( log_file )
      log.log_time_zone = java.util.TimeZone::getDefault.getID
      log.append = true;
      log
    end
    
  end
end
