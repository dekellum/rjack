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

require 'rjack-slf4j'
require 'rjack-slf4j/jcl-over-slf4j'
require 'rjack-commons-codec'
require 'rjack-httpclient-4/base'

require 'java'

module RJack
  module HTTPClient4

    Dir.glob( File.join( HTTPCLIENT_DIR, '*.jar' ) ).each { |jar| require jar }

    import 'org.apache.http.client.params.ClientParamBean'
    import 'org.apache.http.client.params.CookiePolicy'
    import 'org.apache.http.conn.scheme.PlainSocketFactory'
    import 'org.apache.http.conn.params.ConnManagerParamBean'
    import 'org.apache.http.conn.params.ConnPerRouteBean'
    import 'org.apache.http.conn.scheme.Scheme'
    import 'org.apache.http.conn.scheme.SchemeRegistry'
    import 'org.apache.http.conn.ssl.SSLSocketFactory'
    import 'org.apache.http.impl.client.DefaultHttpClient'
    import 'org.apache.http.impl.client.DefaultHttpRequestRetryHandler'
    import 'org.apache.http.impl.conn.tsccm.ThreadSafeClientConnManager'
    import 'org.apache.http.message.BasicHeader'
    import 'org.apache.http.params.BasicHttpParams'
    import 'org.apache.http.params.HttpConnectionParamBean'

    # Facade over http client and connection manager, supporting
    # setup -> start() -> shutdown()
    class ManagerFacade
      # {Manager parameters}[http://hc.apache.org/httpcomponents-client/httpclient/apidocs/org/apache/http/conn/params/ConnManagerParamBean.html]
      # "bean", responding to various setters:
      #
      #  manager_params.max_total_connections     = 200
      #  manager_params.timeout                   = 2000     #milliseconds
      #  manager_params.connections_per_route     = 10
      #
      attr_reader :manager_params

      # {Client parameters}[http://hc.apache.org/httpcomponents-client/httpclient/apidocs/org/apache/http/client/params/ClientParamBean.html]
      # "bean", responding to various setters:
      #
      #  client_params.allow_circular_redirects   = false
      #  client_params.cookie_policy              = CookiePolicy::BEST_MATCH
      #  client_params.default_headers            = { "X-Name" => "value" }
      #  client_params.handle_redirects           = true
      #  client_params.reject_relative_redirect   = true
      #
      attr_reader :client_params

      # {Connection parameters}[http://hc.apache.org/httpcomponents-core/httpcore/apidocs/org/apache/http/params/HttpConnectionParamBean.html]
      # "bean", responding to various setters:
      #
      #  connection_params.connection_timeout     = 2000     #milliseconds
      #  connection_params.so_timeout             = 3000     #milliseconds
      #  connection_params.linger                 = 2        #seconds
      #  connection_params.socket_buffer_size     = 2 * 1024 #bytes
      #  connection_params.stale_checking_enabled = true
      #  connection_params.tcp_no_delay           = false
      #
      attr_reader :connection_params

      # {org.apache.http.client.HttpClient}[http://hc.apache.org/httpcomponents-client/httpclient/apidocs/org/apache/http/client/HttpClient.html]
      # available after start()
      attr_reader :client

      # New facade ready for setup
      def initialize
        @mparams = BasicHttpParams.new
        @cparams = BasicHttpParams.new

        @manager_params    = ConnManagerParamBean.new( @mparams )
        @client_params     = ClientParamBean.new( @cparams )
        @connection_params = HttpConnectionParamBean.new( @cparams )

        @client = nil
        @connection_manager = nil
        @retry_handler = nil
      end

      # Setup a DefaultHttpRequestRetryHandler
      def set_retry_handler( count, retry_if_sent = false )
        @retry_handler =
          DefaultHttpRequestRetryHandler.new( count, retry_if_sent )
      end

      # Given previous setup, create connection manager, create, and
      # return client.
      def start
        @scheme_registry = create_scheme_registry
        @connection_manager = create_connection_manager

        @client = create_http_client
      end

      # Shutdown client and connection manager.
      def shutdown
        @connection_manager.shutdown if @connection_manager
        @client = nil
        @connection_manager = nil
      end

      # Create a default SchemeRegistry with http and https enabled.
      def create_scheme_registry
        sr = SchemeRegistry.new
        sr.register( Scheme.new( "http",  80, plain_factory ) )
        sr.register( Scheme.new( "https", 443, ssl_factory ) )
        sr
      end

      # Return MultihomePlainSocketFactory instance
      def plain_factory
        PlainSocketFactory::socket_factory
      end

      # Return SSLSocketFactory instance
      def ssl_factory
        SSLSocketFactory::socket_factory
      end

      # Create default ThreadSafeClientConnManager using a set manager_params
      def create_connection_manager
        ThreadSafeClientConnManager.new( @mparams, @scheme_registry )
      end

      # Create DefaultHttpClient given connection manager and any set
      # client or connection_params
      def create_http_client
        c = DefaultHttpClient.new( @connection_manager, @cparams )
        c.http_request_retry_handler = @retry_handler if @retry_handler
        c
      end

    end

    # ConnManagerParamBean reopen
    class ConnManagerParamBean
      # Convert to ConnPerRouteBean.new( value ) unless is one.
      def connections_per_route=( value )
        unless value.is_a?( ConnPerRouteBean )
          value = ConnPerRouteBean.new( value.to_i )
        end
        setConnectionsPerRoute( value )
      end
    end

    # ClientParamBean reopen
    class ClientParamBean
      # Convert to [ BasicHeader.new( k,v ) ] if value is hash.
      def default_headers=( value )
        if value.is_a?( Hash )
          value = value.map { |nv| BasicHeader.new( *nv ) }
        end
        setDefaultHeaders( value )
      end
    end

  end
end
