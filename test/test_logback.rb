#!/usr/bin/env jruby
#--
# Copyright (C) 2008 David Kellum
#
# Logback Ruby is free software: you can redistribute it and/or
# modify it under the terms of the 
# {GNU Lesser General Public License}[http://www.gnu.org/licenses/lgpl.html] 
# as published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Logback Ruby is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#++

$LOAD_PATH.unshift File.join( File.dirname(__FILE__), "..", "lib" )

gem( 'slf4j', '~> 1.5.5' )
require 'slf4j'
require 'logback'

# Test load works
require 'logback/access'

require 'test/unit'

class TestAppender
  import 'ch.qos.logback.core.Appender'
  include Appender

  attr_reader :count, :last
  attr_writer :layout

  def initialize
    reset 
  end

  def doAppend( event )
    @count += 1
    @last = event
    @last = @layout.nil? ? event : @layout.doLayout( event )
  end

  def start; end
  def stop; end
  
  def reset
    @count = 0
    @last = nil
    @layout = nil
  end
end

class TestLevelSet < Test::Unit::TestCase

  def setup
    @appender = TestAppender.new
    Logback.configure do 
      Logback.root.add_appender( @appender )
    end
    @log = SLF4J[ "my.app" ]
  end
  
  def teardown
    @appender.reset()
  end

  def test_below_level
    Logback.root.level = Logback::ERROR
    assert( ! @log.debug? )
    @log.debug( "not logged" )
    @log.debug { "also not logged" }
    assert_equal( 0, @appender.count )
  end

  def test_above_level
    Logback.root.level = Logback::TRACE
    assert( @log.trace? )
    @log.trace( "logged" )
    assert_equal( 1, @appender.count )
    assert_equal( Logback::TRACE, @appender.last.level )
    assert_equal( "logged", @appender.last.message )
  end


  def test_override_level
    Logback.root.level = Logback::ERROR
    Logback[ "my" ].level = Logback::WARN
    assert( @log.warn? )
    @log.warn( "override" )
    assert_equal( Logback::WARN, @appender.last.level )
    assert_equal( 1, @appender.count )
  end

end

class TestConfigure < Test::Unit::TestCase
  
  def test_file_appender_config
    log_file = "./test_appends.test_file_appender.log"

    Logback.configure do
      appender = Logback::FileAppender.new( log_file, false ) do |a|
        a.layout = Logback::PatternLayout.new( "%level-%msg" )
        a.immediate_flush = true
        a.encoding = "ISO-8859-1"
      end 
      Logback.root.add_appender( appender )
    end
    log = SLF4J[ self.class.name ]
    log.debug( "write to file" )
    assert( File.file?( log_file ) )
    assert( File.stat( log_file ).size > 0 )
    assert_equal( 1, File.delete( log_file ) )
  end

  def test_pattern_config
    appender = TestAppender.new
    Logback.configure do
      appender.layout = Logback::PatternLayout.new( "%level-%msg" )
      Logback.root.add_appender( appender )
    end

    log = SLF4J[ self.class.name ]
    log.info( "message" )
    assert_equal( 1, appender.count )
    assert_equal( "INFO-message", appender.last )
  end


  def test_console_config
    log_name = "#{self.class.name}.#{self.method_name}"
    appender = TestAppender.new
    Logback.configure do
      console = Logback::ConsoleAppender.new do |a|
        a.immediate_flush = true
        a.encoding = "UTF-8"
        a.target = "System.out"
      end 
      Logback.root.add_appender( console )
      Logback[ log_name ].add_appender( appender )
    end

    Logback[ log_name ].level = Logback::DEBUG
    Logback[ log_name ].additive = false
    log = SLF4J[ log_name ]
    log.debug( "test write to console" )
    assert_equal( 1, appender.count )
  end

end
