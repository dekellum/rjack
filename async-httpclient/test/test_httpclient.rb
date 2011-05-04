#!/usr/bin/env jruby
#--
# Copyright (c) 2011 David Kellum
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
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
RJack::Logback.config_console( :level => RJack::Logback::DEBUG )

require 'test/unit'

$LOAD_PATH.unshift File.join( File.dirname(__FILE__), "..", "lib" )

require 'rjack-async-httpclient'

class TestClient < Test::Unit::TestCase
  include RJack::AsyncHTTPClient

  def test_load

    cfg = build_client_config( { :idle_connection_timeout_in_ms => 10_000,
                                 :connection_timeout_in_ms => 4_000 } )

    client = AsyncHttpClient.new( cfg )
    client.close

  end

end
