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

require File.join( File.dirname( __FILE__ ), "setup" )

module RJack::JMS

  class Tracked
    attr_reader :called

    def initialize
      @called = []
    end

    def method_missing( name, *args )
      called << name
    end
  end

  class Connection < Tracked
    include javax.jms.Connection

    attr_accessor :exception_listener
  end

  class Context < Tracked
    include JMSContext

    def create_connection
      called << :create_connection
      Connection.new
    end
  end

  class Listener < Tracked
    include ConnectListener
  end

  class TestJMSConnector < MiniTest::Unit::TestCase
    import 'javax.jms.JMSException'
    import 'javax.naming.NamingException'

    def setup
      @connector = JMSConnector.new( @context = Context.new )
    end

    def test_start_stop
      @connector.start
      # May or may not actually run in time before stop.
      # But shouldn't dead lock.
      @connector.stop
    end

    def test_start_await_stop
      @connector.add_connect_listener( listener = Listener.new )
      @connector.start

      con = @connector.await_connection
      assert_kind_of( Connection, con )
      assert_includes( listener.called, :onConnect )
      assert_includes( con.called, :start )

      @connector.stop
      assert_includes( @context.called, :close )
    end

    def test_on_exception
      @connector.start

      con = @connector.await_connection
      assert_includes( con.called, :start )

      con.exception_listener.on_exception( JMSException.new( "test" ) )
      assert_includes( con.called, :close )

      con2 = @connector.await_connection
      refute_equal( con, con2 )
      assert_includes( con2.called, :start )

      @connector.stop
      assert_includes( @context.called, :close )
    end

    def test_failed_listener
      @connector.add_connect_listener( listener = Listener.new )

      def listener.on_connect( *args )
        raise NamingException.new( "test" )
      end

      assert_raises( NativeException, NamingException ) do
        @connector.connect_loop
      end

      assert_includes( @context.called, :close )
    end

  end
end
