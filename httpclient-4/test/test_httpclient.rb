#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2008-2014 David Kellum
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

require 'rjack-logback'

RJack::Logback.config_console( :level => RJack::Logback::INFO )
if ARGV.include?( '-v' ) || ARGV.include?( '--verbose' )
  RJack::Logback.root.level = RJack::Logback::DEBUG
end

require 'minitest/unit'
require 'minitest/autorun'

require 'rjack-httpclient-4'

class TestClient < MiniTest::Unit::TestCase
  include RJack::HTTPClient4
  import 'org.apache.http.client.methods.HttpGet'

  def test_setup
    mf = ManagerFacade.new

    mf.manager_params.max_total_connections     = 200
    mf.manager_params.timeout                   = 2000     #milliseconds
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
    refute_nil mf.client

    mf.shutdown
    assert_nil mf.client
  end

  def test_get
    mf = ManagerFacade.new
    mf.start
    client = mf.client
    res = client.execute( HttpGet.new( "http://rjack.gravitext.com" ) )
    assert( 200, res.status_line.status_code )
  ensure
    res.close if res
    mf.shutdown if mf
  end

end
