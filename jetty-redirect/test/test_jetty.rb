#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2008-2011 David Kellum
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

$LOAD_PATH.unshift File.join( File.dirname( __FILE__ ), "..", "lib" )

require 'rubygems'

gem( 'rjack-jetty', '>= 6.1.26', '< 7' )

require 'jetty'
require 'jetty/rewrite'
require 'jetty/test-servlets'

require 'test/unit'
require 'net/http'

class TestJetty < Test::Unit::TestCase
  include Jetty

  def default_factory
    factory = ServerFactory.new
    factory.max_threads = 1
    factory.stop_at_shutdown = false
    factory
  end

  def test_start_stop
    factory = default_factory
    server = factory.create
    server.start
    assert( server.is_started )
    assert( server.connectors[0].local_port > 0 )
    server.stop
    server.join
    assert( server.is_stopped )
  end

end
