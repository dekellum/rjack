#--
# Copyright (C) 2008 David Kellum
#
# Logback Ruby is free software: you can redistribute it and/or
# modify it under the terms of the 
# {GNU Lesser General Public License}[http://www.gnu.org/licenses/lgpl.html] 
# as published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Logback Ruby is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#++

require 'rubygems'

require 'jetty/base'

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

    def create_pool
      pool = QueuedThreadPool.new
      pool.min_threads = [ @min_threads || ( @max_threads / 4 ), 1 ].max
      pool.low_threads = @low_threads
      pool.max_threads = [ @max_threads, 2 ].max
      pool
    end

    # Return array of org.mortbay.jetty.Connector instances.
    # This implementation returns a single SelectChannelConnector
    def create_connectors
      connector = SelectChannelConnector.new
      connector.port = @port
      connector.max_idle_time = @max_idle_time_ms
      [ connector ]
    end

    def create_handlers
      ( create_pre_handlers + create_post_handlers )
    end

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

    def create_post_handlers
      [ DefaultHandler.new, # Handle errors, etc.
        create_request_log_handler ]
    end

    def create_context_handlers( context_handler_collection )
      create_static_contexts( context_handler_collection )
      create_webapp_contexts( context_handler_collection )
      create_servlet_contexts( context_handler_collection )
    end

    def create_static_contexts( context_handler_collection )
      @static_contexts.each do |ctx, rpath|
        ch = ContextHandler.new( context_handler_collection, ctx )
        ch.resource_base = rpath
        ch.handler = ResourceHandler.new
        ch.handler.welcome_files = 
          @static_welcome_files.to_java( java.lang.String )
      end
    end

    def set_context_servlets( context_path, servlets, options = Context::NO_SESSIONS )
      @servlet_contexts[ context_path ] = [ servlets, options ]
    end

    def create_servlet_contexts( context_handler_collection )
      @servlet_contexts.each do |ctx, s_o|
        servlets, options = s_o
        context = Context.new( context_handler_collection, ctx, options )
        servlets.each do |path, servlet|
          context.add_servlet( ServletHolder.new( servlet ), path )
        end
      end
    end

    def create_webapp_contexts( context_handler_collection )
      @webapp_contexts.each do |ctx, webapp_path|
        WebAppContext.new( context_handler_collection, webapp_path, ctx )
      end
    end    

    def create_request_log_handler
      if @request_log_file
        log_handler = RequestLogHandler.new
        log_handler.request_log = create_request_log( @request_log_file )
        log_handler
      end
    end

    def create_request_log( log_file )
      log = NCSARequestLog.new( log_file )
      log.log_time_zone = java.util.TimeZone::getDefault.getID
      log.append = true;
      log
    end
    
  end

end
