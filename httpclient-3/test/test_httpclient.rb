#!/usr/bin/env jruby
#--
# Copyright (c) 2008-2010 David Kellum
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
gem( 'rjack-logback', '>= 0.9.17.1' )

require 'rjack-logback'
Logback.config_console( :level => Logback::DEBUG )

require 'test/unit'

$LOAD_PATH.unshift File.join( File.dirname(__FILE__), "..", "lib" )

require 'rjack-httpclient-3'

class TestClient < Test::Unit::TestCase
  include RJack::HTTPClient3
  def test_setup
    m = ManagerFacade.new
    m.manager_params.max_total_connections = 200
    m.client_params.so_timeout = 3000 #ms
    m.start

    assert_not_nil m.client

    m.shutdown

    assert_nil m.client
  end
end
