#!/usr/bin/env jruby
#--
# Copyright (C) 2008-2009 David Kellum
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
gem( 'logback', '>= 0.9.15.2' )

require 'logback'
Logback.config_console( :level => Logback::DEBUG )

require 'test/unit'

$LOAD_PATH.unshift File.join( File.dirname(__FILE__), "..", "lib" )

require 'rjack-httpclient'

class TestClient < Test::Unit::TestCase
  include RJack::HTTPClient
  def test_setup
    mf = ManagerFacade.new

    mf.manager_params.max_total_connections     = 200
    mf.manager_params.timeout                   = 2000 #milliseconds
    mf.manager_params.connections_per_route     = 10
    mf.client_params.allow_circular_redirects   = false
    mf.client_params.cookie_policy              = CookiePolicy::BEST_MATCH
    mf.client_params.default_headers            = { "X-Name" => "value" }
    mf.client_params.handle_redirects           = true
    mf.client_params.reject_relative_redirect   = true
    mf.connection_params.connection_timeout     = 2000     #milliseconds
    mf.connection_params.so_timeout             = 3000     #milliseconds
    mf.connection_params.linger                 = 2        #seconds
    mf.connection_params.socket_buffer_size     = 2 * 1024 #bytes
    mf.connection_params.stale_checking_enabled = true
    mf.connection_params.tcp_no_delay           = false

    mf.set_retry_handler( 2 )

    mf.start

    assert_not_nil mf.client

    mf.shutdown

    assert_nil mf.client
  end
end
