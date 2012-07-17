#--
# Copyright (c) 2012 David Kellum
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

require 'rjack-jetty-jsp'

require 'rjack-solr/base'
require 'rjack-solr'
require 'rjack-solr/config'

module RJack
  module Solr

    WEBAPP_PATH = File.expand_path( '../../../webapp', __FILE__ )

    class Server < RJack::Jetty::ServerFactory

      attr_accessor :solr_home

      def initialize()
        super()

        puts WEBAPP_PATH
        self.webapp_contexts[ '/' ] = WEBAPP_PATH
        self.port = 8983
        @solr_home = '.'

        Hooker.apply( [ :solr, :http_server ], self )
      end

      def create_request_log( log_file )
        super.tap do |log|
          log.extended = true
          log.log_latency = true
        end
      end

      def start
        Java::java.lang.System.set_property( 'solr.solr.home', @solr_home )

        @server = create
        @server.start
        self.port = @server.connectors[0].local_port

        @server
      end

      def join
        @server.join if @server
      end

      def stop
        @server.stop if @server
      end

    end
  end
end
