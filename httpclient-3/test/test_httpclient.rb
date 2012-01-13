#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2008-2012 David Kellum
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

require 'rjack-logback'

RJack::Logback.config_console( :level => RJack::Logback::DEBUG )
if ARGV.include?( '-v' ) || ARGV.include?( '--verbose' )
  RJack::Logback.root.level = RJack::Logback::DEBUG
end

require 'minitest/unit'
require 'minitest/autorun'

require 'rjack-httpclient-3'

class TestClient < MiniTest::Unit::TestCase
  include RJack::HTTPClient3
  def test_setup
    m = ManagerFacade.new
    m.manager_params.max_total_connections = 200
    m.client_params.so_timeout = 3000 #ms
    m.start

    refute_nil m.client

    m.shutdown

    assert_nil m.client
  end
end
