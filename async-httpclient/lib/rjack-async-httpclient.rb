#--
# Copyright (c) 2011 David Kellum
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

require 'rjack-slf4j'
require 'rjack-async-httpclient/base'

require 'java'

module RJack
  module AsyncHTTPClient

    Dir.glob( File.join( CLIENT_DIR, '*.jar' ) ).each { |jar| require jar }

    import 'com.ning.http.client.AsyncHttpClientConfig'
    import 'com.ning.http.client.AsyncHttpClient'

    # Extensions to com.ning.http.client.AsyncHttpClientConfig supporting
    # inspection as a options hash.
    class AsyncHttpClientConfig

      GET_TO_SETTERS = {
        :async_http_provider_config     => :async_http_client_provider_config,
        :max_connection_per_host        => :maximum_connections_per_host,
        :max_redirects                  => :maximum_number_of_redirects,
        :max_total_connections          => :maximum_connections_total,
        :reaper                         => :scheduled_executor_service,
        :redirect_enabled               => :follow_redirects,
        :remove_query_param_on_redirect => :remove_query_params_on_redirect,
        :ssl_connection_pool_enabled    => :allow_ssl_connection_pool
      }

      def to_hash
        props = self.methods.
          map { |m| m =~ /^(is|get)_([a-z0-9_]+)$/ && $2 }.
          compact

        props -= %w[ class closed ]            #bogus
        props += %w[ reaper executor_service ] #without get_

        props.map! { |p| p.to_sym }
        props.inject( {} ) do |h,p|
          h[ GET_TO_SETTERS[ p ] || p ] = send( p )
          h
        end
      end

      def to_s
        out = "{ "
        kv = to_hash.sort { |p,n| p[0].to_s <=> n[0].to_s }
        kv.each do |k,v|
          out << ",\n  " if out.length > 2
          out << ":#{ k } => #{ v_inspect( v ) }"
        end
        out << " }"
        out
      end

      private

      def v_inspect( v )
        v.respond_to?( :java_class ) ? v.to_string : v.inspect
      end
    end

    module_function

    def build_client( options )
      AsyncHttpClient.new( build_client_config( options ) )
    end

    def build_client_config( options )
      builder = AsyncHttpClientConfig::Builder.new
      options.each do |k,v|
        builder.send( "set_#{k}", v )
      end
      builder.build
    end

  end
end
