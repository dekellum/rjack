#--
# Copyright (c) 2011-2012 David Kellum
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

# Base class for mocks, keeps a called list
class TrackingMock
  attr_reader :called

  def initialize
    @called = []
  end

  def method_missing( name, *args )
    called << name
  end
end

class Connection < TrackingMock
  include javax.jms.Connection

  attr_accessor :exception_listener
end

class Context < TrackingMock
  include RJack::JMS::JMSContext

  def create_connection
    called << :create_connection
    Connection.new
  end

  def create_session( *args )
    called << :create_session
    TrackingMock.new
  end

end

class Listener < TrackingMock
  include RJack::JMS::ConnectListener
end

class TestSessionStateFactory < TrackingMock
  include RJack::JMS::SessionStateFactory

  attr_reader :last_session
  attr_reader :session_count

  def create_session_state( *args )
    called << :create_session_state
    @session_count ||= 0
    @session_count += 1
    @last_session = TestSessionState.new( *args )
  end

end

class TestSessionState < RJack::JMS::SessionState
  def close
    super
    @closed = true
  end

  def closed?
    @closed
  end
end

class TestSessionTask < RJack::JMS::SessionTask
  def initialize( &block )
    super()
    @block = block
  end

  def runTask( state )
    @block.call( state )
  end
end
