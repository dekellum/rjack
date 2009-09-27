#--
# Copyright (C) 2008-2009 David Kellum
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

require 'rubygems'

require 'rjack-slf4j'
require 'rjack-slf4j/jcl-over-slf4j'
require 'rjack-commons-codec'
require 'rjack-httpclient/base'

module RJack
  module HTTPClient

    Dir.glob( File.join( HTTPCLIENT_DIR, '*.jar' ) ).each { |jar| require jar }

    import 'org.apache.commons.httpclient.params.HttpConnectionManagerParams'
    import 'org.apache.commons.httpclient.params.HttpClientParams'
    import 'org.apache.commons.httpclient.params.HttpMethodParams'
    import 'org.apache.commons.httpclient.DefaultHttpMethodRetryHandler'
    import 'org.apache.commons.httpclient.MultiThreadedHttpConnectionManager'
    import 'org.apache.commons.httpclient.HttpClient'

    # Facade over http client and connection manager, setup, start, shutdown
    #
    # == Example Settings
    #
    # See: http://hc.apache.org/httpclient-3.x/preference-api.html
    #
    #  manager_params.max_total_connections = 200
    #  manager_params.connection_timeout = 1500 #ms
    #  manager_params.default_max_connections_per_host = 20
    #  manager_params.stale_checking_enabled = false
    #  client_params.connection_manager_timeout = 3000 #ms
    #  client_params.so_timeout = 3000 #ms
    #  client_params.set_parameter( HttpMethodParams::RETRY_HANDLER,
    #                               DefaultHttpMethodRetryHandler.new( 2, false ) )
    #  client_params.cookie_policy = CookiePolicy::IGNORE_COOKIES
    #
    # Expect incompatible changes to these setting upon upgrade to 4.0
    class ManagerFacade

      # The HttpClient instance available after start
      attr_reader :client

      # Manager parameters
      attr_reader :manager_params

      # Client parameters
      attr_reader :client_params

      def initialize
        @manager_params = HttpConnectionManagerParams.new

        @client_params = HttpClientParams.new

        @client = nil
        @connection_manager = nil
      end

      # Given previously set parameters, construct connection manager
      # and client.
      def start
        @connection_manager = MultiThreadedHttpConnectionManager.new()
        @connection_manager.params = @manager_params

        @client = HttpClient.new( @client_params, @connection_manager );
      end

      # Shutdown and close the connection manager and client.
      def shutdown
        @connection_manager.shutdown if @connection_manager
        @client = nil
        @connection_manager = nil
      end
    end
  end
end
