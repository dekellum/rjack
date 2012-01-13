#--
# Copyright (c) 2009-2012 David Kellum
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
require 'rjack-httpclient-3'
require 'rjack-jets3t/base'

require 'java'

module RJack
  module JetS3t
    import 'org.jets3t.service.acl.AccessControlList'
    import 'org.jets3t.service.model.S3Object'

    # Facade over org.jets3t.service.model.S3Bucket
    class S3Bucket

      #import 'org.jets3t.service.model.S3Bucket'
      #import 'org.jets3t.service.impl.rest.httpclient.RestS3Service'
      #import 'org.jets3t.service.security.AWSCredentials'
      #import 'org.jets3t.service.Jets3tProperties'

      # The S3Service from in which this bucket resides
      attr_reader :service

      # The underlying org.jets3t.service.model.S3Bucket
      attr_reader :jbucket

      # Hostname/prefix used use when composing HTTP access URLs.
      attr_accessor :host_prefix

      # Default ACL for put
      attr_accessor :default_acl

      # New bucket wrapper
      #
      # ==== Parameters
      # service<S3Service>:: S3Service in which this bucket resides
      # jbucket<org.jets3t.service.model.S3Bucket>:: the bucket
      #
      # ==== Options (opts)
      # :host_prefix<~to_s>:: Host name/prefix to use when composing access
      #                       URLs. (Default: s3.amazonaws.com/bucket-name)
      # :default_acl<AccessControlList>:: Default ACL for put
      #          (Default: AccessControlList::REST_CANNED_PUBLIC_READ)
      #
      # ==== Raises
      # :S3ServiceException:: From JetS3t
      # :RuntimeError:: On failure to provide required options
      def initialize( service, jbucket, opts = {} )
        @service = service
        @jbucket = jbucket
        @host_prefix   = ( opts[ :host_prefix ] ||
                           [ 's3.amazonaws.com', jbucket.name ].join( '/' ) )
        @default_acl = ( opts[ :default_acl ] ||
                         AccessControlList::REST_CANNED_PUBLIC_READ )
      end

      # Bucket name
      def name
        @jbucket.name
      end

      # Put object in this S3 bucket at the given name (key). Yields
      # S3Object for setting content, acl or other overrides. Returns
      # external HTTP url using :host_prefix
      # ==== Raises
      # :S3ServiceException:: From JetS3t
      def put( name, mime_type )
        obj = S3Object.new( @jbucket, name )
        obj.content_type = mime_type
        obj.acl = @default_acl
        yield obj
        @service.jservice.put_object( @jbucket, obj )
        "http://%s/%s" % [ @host_prefix, name ]
      end

      # Delete object with the given name in this bucket
      # ==== Raises
      # :S3ServiceException:: From JetS3t
      def delete( name )
        @service.jservice.delete_object( @jbucket, name )
      end

    end

  end
end
