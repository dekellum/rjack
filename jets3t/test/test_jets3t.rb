#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived
#--
# Copyright (c) 2009-2010 David Kellum
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

$LOAD_PATH.unshift File.join( File.dirname(__FILE__), "..", "lib" )

require 'rubygems'
require 'rjack-logback'

RJack::Logback.config_console( :level => RJack::Logback::INFO )

require 'rjack-jets3t'

require 'test/unit'

class TestJets3t < Test::Unit::TestCase
  include RJack::JetS3t

  import "java.io.ByteArrayInputStream"

  def test_loaded
    assert true
  end

  # Create a test_opts.yaml with creds to account with at least one
  # bucket for a real test.
  #
  #   ---
  #   :credentials:
  #   - access-key
  #   - secret-key

  if File.exists?( 'test_opts.yaml' )

    def setup
      opts = File.open( 'test_opts.yaml' ) { |f| YAML::load( f ) }
      @s3 = S3Service.new( opts )
      @tbucket = @s3.create_bucket( "test.rjack.rubyforge.org" )
    end

    def teardown
      @s3.delete_bucket( @tbucket ) if @tbucket
    end

    def test_write
      assert( @s3.buckets.any? { |b| b.name == @tbucket.name } )

      url = @tbucket.put( "testkey", "text/plain" ) do |obj|
        data = "hello"
        obj.data_input_stream = ByteArrayInputStream.new( data.to_java_bytes )
        obj.content_length = data.length
      end
      assert_equal( 'http://s3.amazonaws.com/test.rjack.rubyforge.org/testkey',
                    url )
      @tbucket.delete( "testkey" )
    end

  end

end
