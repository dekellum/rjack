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

RJack::Logback.config_console( :stderr => true, :level => RJack::Logback::WARN )
if ARGV.include?( '-v' ) || ARGV.include?( '--verbose' )
  RJack::Logback.root.level = RJack::Logback::DEBUG
end

require 'minitest/unit'
require 'minitest/autorun'

$LOAD_PATH.unshift File.join( File.dirname(__FILE__), "..", "lib" )

require 'rjack-async-httpclient'

class TestClient < MiniTest::Unit::TestCase
  include RJack::AsyncHTTPClient

  def test_load

    cfg = build_client_config( { :idle_connection_timeout_in_ms => 10_000,
                                 :connection_timeout_in_ms => 4_000 } )

    client = AsyncHttpClient.new( cfg )
    client.close

  end

  def test_default_config
    RJack::SLF4J[ self.class ].debug do
      "Default config:\n" + build_client_config( {} ).to_s
    end
    pass
  end

  def test_config_as_hash_round_trip
    sfun = method :select_basic

    cfg0 = build_client_config( {} )
    basics0 = cfg0.to_hash.select &sfun

    cfg1 = build_client_config( basics0 )
    basics1 = cfg1.to_hash.select &sfun

    assert_equal( basics0, basics1 )
  end

  def select_basic( _, value )
    ! value.respond_to?( :java_class )
  end

end
