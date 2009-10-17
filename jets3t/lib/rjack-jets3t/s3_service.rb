#--
# Copyright (C) 2009 David Kellum
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
require 'rjack-httpclient-3'
require 'rjack-jets3t/base'

module RJack
  module JetS3t
    import 'org.jets3t.service.S3ServiceException'
    import 'org.jets3t.service.model.S3Bucket'

    # Initialization Wrapper around
    # RestS3Service[http://jets3t.s3.amazonaws.com/api/org/jets3t/service/impl/rest/httpclient/RestS3Service.html]
    class S3Service
      import 'org.jets3t.service.impl.rest.httpclient.RestS3Service'
      import 'org.jets3t.service.security.AWSCredentials'
      import 'org.jets3t.service.Jets3tProperties'

      # The org.jets3t.service.impl.rest.httpclient.RestS3Service
      attr_reader :service

      # New REST S3 service instance given options hash.
      # ==== Options (opts)
      # :credentials<Array[String,String]>:: Required [access,secret] key
      # :http_client<org.apache.commons.HttpClient>:: A pre-configured replacement
      #                                               HttpClient (3.x) (Default: JetS3t provided)
      # String<~to_s>:: Other options as defined in
      #                 {JetS3t Properties}[http://jets3t.s3.amazonaws.com/toolkit/configuration.html].
      #                 HTTP client properties only apply to JetS3t's default
      #                 client (:http_client not set), and the timeout
      #                 parameters are here defaulted to 5 seconds vs. the JetS3t
      #                 60 second originals.
      #
      # ==== Raises
      # :S3ServiceException:: From JetS3t
      # :RuntimeError:: On failure to provide required options
      def initialize( opts = {} )
        opts = opts.dup

        creds = opts.delete( :credentials )
        unless creds && (2..3) === creds.length
          raise "Missing required :credentials [public,secret] keys"
        end
        creds = AWSCredentials.new( *creds )

        http = opts.delete( :http_client )
        unless http
          hdefs = { 'httpclient.connection-timeout-ms' => 5000,
                    'httpclient.socket-timeout-ms'     => 5000 }
          opts = hdefs.merge( opts )
        end

        props = Jets3tProperties.new
        opts.each { |k,v| props.set_property( k, v.to_s ) }

        @service = RestS3Service.new( creds, nil, nil, props )

        @service.http_client = http if http
      end

    end

  end
end
