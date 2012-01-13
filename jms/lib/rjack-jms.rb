#--
# Copyright (c) 2011-2012 David Kellum
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

require 'rjack-jms/base'

require 'rjack-jms-spec'
require 'rjack-slf4j'

require 'java'

module RJack
  module JMS
    require "rjack-jms/rjack-jms-#{VERSION}.jar"

    import 'rjack.jms.ConnectListener'
    import 'rjack.jms.JMSConnector'
    import 'rjack.jms.JMSContext'
    import 'rjack.jms.JMSRuntimeException'
    import 'rjack.jms.SessionExecutor'
    import 'rjack.jms.SessionState'
    import 'rjack.jms.SessionStateFactory'
    import 'rjack.jms.SessionTask'
  end
end
