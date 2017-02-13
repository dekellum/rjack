#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2008-2017 David Kellum
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
require 'bundler/setup'

# Disable Jetty Logging
require 'rjack-slf4j'
require 'rjack-slf4j/nop'

require 'minitest/unit'
require 'minitest/autorun'

require 'rjack-jetty-jsp'
require 'net/http'

class TestJsp < MiniTest::Unit::TestCase
  include RJack::Jetty

  def default_factory
    factory = ServerFactory.new
    factory.max_threads = 1
    factory.stop_at_shutdown = false
    factory
  end

  def test_webapp
    factory = default_factory
    factory.webapp_contexts[ '/' ] = Jsp::TEST_WAR

    server = factory.create
    server.start
    port = server.connectors[0].local_port

    jsp_out = Net::HTTP.get( 'localhost', '/', port )
    assert( jsp_out =~ /Hello World!/, jsp_out )

    server.stop
  end
end
