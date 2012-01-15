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

#### General test setup: LOAD_PATH, logging, console output ####

require 'rubygems'
require 'bundler/setup'

test_dir = File.dirname( __FILE__ )
$LOAD_PATH.unshift( test_dir ) unless $LOAD_PATH.include?( test_dir )

require 'rjack-logback'

require 'rjack-jms'

require 'minitest/unit'
require 'minitest/autorun'

RJack::Logback.config_console( :stderr => true )

if ARGV.include?( '-v' ) || ARGV.include?( '--verbose' )

  RJack::Logback.root.level = RJack::Logback::DEBUG
  RJack::Logback[ 'rjack.jms.JMSConnector' ].level = RJack::Logback::INFO

  # Make test output logging compatible: no partial lines.
  class TestOut
    def print( *a ); $stdout.puts( *a ); end
    def puts( *a );  $stdout.puts( *a ); end
  end
  MiniTest::Unit.output = TestOut.new

else
  #Squelch test logging
  RJack::Logback[ 'rjack.jms' ].level = RJack::Logback::ERROR
end
