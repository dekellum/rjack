#!/usr/bin/env jruby
#--
# Copyright 2008 David Kellum
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

$LOAD_PATH.unshift File.join( File.dirname(__FILE__), "..", "lib" )

require 'slf4j'

# Load jdk14 implementation for testing
require 'slf4j/jdk14'

# Load these only to confirm loading works
require 'slf4j/jcl-over-slf4j'
require 'slf4j/log4j-over-slf4j'

require 'test/unit'

class TestHandler < java.util.logging.Handler
  attr_accessor :count, :last

  def initialize
    reset
  end

  def flush; end
  def close; end
  
  def publish( record )
    @count += 1
    @last = record
  end

  def reset
    @count = 0
    @last = nil
  end
end

class TestSlf4j < Test::Unit::TestCase
  JdkLogger = java.util.logging.Logger
  def setup
    @handler = TestHandler.new
    @jdk_logger = JdkLogger.getLogger "" 
    @jdk_logger.addHandler @handler 
    @jdk_logger.level = java.util.logging.Level::INFO
    @log = SLF4J.logger "my.app" 
  end
  
  def teardown
    @handler.reset
  end

  def test_logger
    assert !@log.trace?
    @log.trace( "not written" )
    assert !@log.debug?
    @log.debug { "also not written" }
    assert @log.info?
    @log.info { "test write info" }
    assert @log.warn?
    @log.warn { "test write warning" }
    assert @log.error?
    @log.error( "test write error" )
    assert @log.fatal?
    @log.fatal { "test write fatal --> error" }
    assert_equal( 4, @handler.count )
  end

  def test_circular_ban
    assert_raise( RuntimeError ) do
      require 'slf4j/jul-to-slf4j'
    end
  end

end
