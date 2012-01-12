#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2011 David Kellum
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

RJack::Logback.config_console( :stderr => true )
if ARGV.include?( '-v' ) || ARGV.include?( '--verbose' )
  RJack::Logback.root.level = RJack::Logback::DEBUG
end

require 'minitest/unit'
require 'minitest/autorun'

require 'rjack-qpid-client'

class TestQpidClient < MiniTest::Unit::TestCase
  include RJack::QpidClient

  import 'org.apache.qpid.jms.Session'

  def test_qpid_loaded
    assert( Session )
  end

  def test_default_connection
    with_context do |ctx|
      assert( con = ctx.create_connection )
      con.close
    end
  end

  def test_dest_queue
    con = nil
    with_context do |ctx|
      ctx.destinations[ 'rjack-qpid-test-q' ] = {
        :assert => :always,
        :create => :always,
        :node   => {
          :type       => :queue,
          'x-declare' => {
            'auto-delete' => true,
            :exclusive    => true,
            :arguments => {
              'qpid.max_size'    => 200,
              'qpid.policy_type' => :ring,
            }
          }
        }
      }
      assert( con = ctx.create_connection )
      assert( session = ctx.create_session( con ) )
      assert( ctx.lookup_destination( 'rjack-qpid-test-q' ) )
    end
  ensure
    con.close if con
  end

  def test_dest_exchange
    con = nil
    with_context do |ctx|

      ctx.destinations[ 'rjack-qpid-test-x' ] = {
        :assert => :always,
        :create => :always,
        :node   => {
          :type       => :topic,
          'x-declare' => {
            :type     => :fanout,
            :exchange => 'rjack-qpid-test-x'
          }
        }
      }

      ctx.destinations[ 'rjack-qpid-test-x-q' ] = {
        :assert  => :always,
        :create  => :always,
        :delete  => :always,
        :node    => {
          :type        => :queue,
          'x-bindings' => [ { :exchange => 'rjack-qpid-test-x' } ],
          'x-declare'  => {
            'auto-delete' => true,
            :exclusive    => true,
            :arguments    => {
              'qpid.max_size'    => 200_000,
              'qpid.policy_type' => :ring,
            }
          }
        }
      }
      assert( con = ctx.create_connection )
      assert( session = ctx.create_session( con ) )
      assert( ctx.lookup_destination( 'rjack-qpid-test-x' ) )
      assert( ctx.lookup_destination( 'rjack-qpid-test-x-q' ) )
    end
  ensure
    con.close if con
  end

  def with_context
    ctx = QpidJMSContext.new
    yield ctx
  ensure
    ctx.close if ctx
  end

end
