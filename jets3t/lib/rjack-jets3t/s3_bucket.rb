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

require 'rjack-jets3t/java'

module RJack::JetS3t
  import 'org.jets3t.service.acl.AccessControlList'
  import 'org.jets3t.service.model.S3Object'

  # Facade over org.jets3t.service.model.S3Bucket
  class S3Bucket

    # The S3Service in which this bucket resides
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

    # Put object in this S3 bucket at the given key. Yields
    # S3Object for setting content, acl or other overrides if
    # given. Optional data may be passed as a Ruby String which will
    # be converted to java_bytes. Returns external HTTP url using
    # :host_prefix
    # ==== Raises
    # :S3ServiceException:: From JetS3t
    def put( key, mime_type, rbytes = nil )
      if rbytes
        rbytes = rbytes.to_java_bytes if rbytes.respond_to?( :to_java_bytes )
        obj = S3Object.new( key, rbytes )
      else
        obj = S3Object.new( @jbucket, key )
      end
      obj.content_type = mime_type
      obj.acl = @default_acl
      yield obj if block_given?
      @service.jservice.put_object( @jbucket, obj )
      "http://%s/%s" % [ @host_prefix, key ]
    end

    # Get and yield S3Object from this S3 bucket for the given
    # key. Ensures that on return from block, the objects
    # date_input_stream will be closed.
    # ==== Raises
    # :S3ServiceException:: From JetS3t
    def get( key )
      obj = @service.jservice.get_object( @jbucket.name, key )
      yield obj
      nil
    ensure
      if obj
        din = obj.data_input_stream
        din.close if din
     end
    end

    # Delete object with the given name in this bucket
    # ==== Raises
    # :S3ServiceException:: From JetS3t
    def delete( name )
      @service.jservice.delete_object( @jbucket, name )
    end

  end

end
