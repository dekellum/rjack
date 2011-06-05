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
