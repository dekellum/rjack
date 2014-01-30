#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2011-2014 David Kellum
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

require 'mocks'

class TestExecutor < MiniTest::Unit::TestCase
  include RJack::JMS

  import 'javax.jms.JMSException'

  def setup
    @connector = JMSConnector.new( @context = Context.new )
    @session_factory = TestSessionStateFactory.new
    @executor = SessionExecutor.new( @connector,
                                     @session_factory,
                                     3,  #queue length
                                     1 ) #threads
    @connector.start
  end

  def teardown
    shutdown
    @connector.stop
    @connector = nil
  end

  def shutdown
    if @executor
      @executor.shutdown
      @executor.awaitTermination( 3, java.util.concurrent.TimeUnit::SECONDS )
      @executor = nil
    end
  end

  def test_start_shutdown
  end

  def test_execute
    ran = false

    task = TestSessionTask.new do |session_state|
      ran = true
      assert_kind_of( TestSessionState, session_state )
    end

    @executor.execute( task )

    shutdown
    assert( ran, "Test task should have run by now" )

    sleep 0.1 #FIXME: awaitTerminate can return before SessionThread.close
    assert( @session_factory.last_session.closed?,
            "SessionState should be closed" )
  end

  def test_execute_many

    runs = 0
    5.times { @executor.execute( TestSessionTask.new { runs += 1 } ) }

    shutdown
    assert_equal( 5, runs, "All 5 tasks should have run" )

    sleep 0.1 #FIXME: awaitTerminate can return before SessionThread.close
    assert( @session_factory.last_session.closed?,
            "SessionState should be closed" )
    assert_equal( 1, @session_factory.session_count,
                     "Should run all in one session." )
  end

  def test_jms_exception
    task = TestSessionTask.new { raise JMSException.new( "test" ) }
    @executor.execute( task )

    ran = false
    @executor.execute( TestSessionTask.new { ran = true } )

    shutdown
    assert( ran, "Test task should have run by now" )
    assert_equal( 2, @session_factory.session_count,
                  "Two sessions given first task failure." )
  end

end
