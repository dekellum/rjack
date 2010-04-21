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
gem( 'rjack-slf4j',   '~> 1.5.8' )
gem( 'rjack-logback', '~> 0.9.17' )

require 'rjack-logback'

include RJack

Logback.config_console( :level => Logback::INFO )

require 'rjack-jets3t'

require 'test/unit'

class TestJets3t < Test::Unit::TestCase
  include JetS3t

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
    def test_list
      opts = File.open( 'test_opts.yaml' ) { |f| YAML::load( f ) }
      s3 = S3Service.new( opts )
      buckets = s3.service.list_all_buckets
      assert( buckets.length > 0 )
      puts buckets.map { |b| b.name }
    end
  end

end
