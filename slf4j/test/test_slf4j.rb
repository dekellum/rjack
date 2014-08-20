#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2008-2014 David Kellum
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++

require 'rubygems'
require 'bundler/setup'

require 'rjack-slf4j'

# Load jdk14 implementation for testing
require 'rjack-slf4j/jdk14'

# Now safe to load:
require 'rjack-slf4j/mdc'

# Load these only to confirm loading works
require 'rjack-slf4j/jcl-over-slf4j'
require 'rjack-slf4j/log4j-over-slf4j'

require 'minitest/unit'
require 'minitest/autorun'

class TestHandler < java.util.logging.Handler
  attr_accessor :count, :last

  def initialize
    super
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

module Foo
  module Bar
    class Baz
    end
  end
end

class TestSlf4j < MiniTest::Unit::TestCase
  include RJack
  JdkLogger = java.util.logging.Logger

  def setup
    @handler = TestHandler.new
    @jdk_logger = JdkLogger.getLogger ""
    @jdk_logger.addHandler @handler
    @jdk_logger.level = java.util.logging.Level::INFO
    @log = SLF4J[ "my.app" ]
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

  def test_native_exception
    jlist = Java::java.util.ArrayList.new
    jlist.add( 33 )
    ex = nil
    begin
      jlist.get( 666 ) # IndexOutOfBoundsException
    rescue Java::java.lang.IndexOutOfBoundsException => x
      ex = x
      @log.error( "test java exception", x )
    end
    assert_equal( 1, @handler.count )
    assert_same( ex.cause, @handler.last.thrown )
  end

  def test_ruby_exception
    begin
      0/0 # ZeroDivisionError
    rescue ZeroDivisionError => x
      @log.error( x )
    end
    assert_equal( 1, @handler.count )
  end

  def test_ruby_exception_msg
    msg = "my message".freeze
    begin
      0/0 # ZeroDivisionError
    rescue ZeroDivisionError => x
      @log.error( msg, x )
    end
    assert_equal( 1, @handler.count )
  end

  def test_ruby_exception_block
    begin
      0/0 # ZeroDivisionError
    rescue ZeroDivisionError => x
      @log.error( x ) { "ruby exception" }
    end
    assert_equal( 1, @handler.count )
  end

  def test_to_log_name
    assert_equal( "foo.bar.Baz",
                  SLF4J.to_log_name( Foo::Bar::Baz ) )
    assert_equal( "foo.bar.Baz", SLF4J[ Foo::Bar::Baz ].name )
  end

  def test_circular_ban
    assert_raises( RuntimeError ) do
      require 'rjack-slf4j/jul-to-slf4j'
    end
  end

end

require 'logger'

class TestCompatibility < MiniTest::Unit::TestCase

  def setup
    @jdk_logger = java.util.logging.Logger::getLogger( "" )
    @jdk_logger.level = java.util.logging.Level::ALL
    @jdk_logger.handlers.each do |h|
      h.level = java.util.logging.Level::ALL
    end
  end

  def test_ruby_logger
    # minitest mucks with STDOUT? So use file...
    File.open( File.expand_path( '../logger.out', __FILE__ ), 'w' ) do |fout|
      logger_like?( ::Logger.new( fout ) )
    end
  end

  def test_slf4j_logger
    logger_like?( RJack::SLF4J['compat'] )
  end

  def logger_like?( l )
    assert_equal( ::Logger::DEBUG, l.level )
    l.level = ::Logger::INFO
    assert_equal( ::Logger::INFO, l.level )

    l.sev_threshold = ::Logger::INFO
    assert_equal( ::Logger::INFO, l.sev_threshold )

    assert_equal( true,  l.info? )

    assert_equal( true, l.add( ::Logger::INFO, 'message', 'program' ) )
    assert_equal( true, l.add( ::Logger::INFO, 'message' ) )
    assert_equal( true, l.add( ::Logger::INFO ) )
    assert_equal( true, l.add( ::Logger::INFO ) { "message" } )

    assert_equal( true, l.log( ::Logger::INFO, 'message' ) )

    assert_equal( true, l.info( "message" ) )
    assert_equal( true, l.info( "progname" ) { "message" } )
    assert_equal( true, l.info( "message" ) )
    assert_equal( true, l.info( RuntimeError.new( "exception" ) ) )
    assert_equal( true, l.info( RuntimeError.new( "exception" ) ) { "other" } )

    l << 'dump'

    assert_nil( l.datetime_format )
    l.datetime_format = '%Y-%m-%d %H:%M:%S'
    assert_equal( '%Y-%m-%d %H:%M:%S', l.datetime_format )

    assert_nil( l.formatter )
    l.formatter = x = proc {}
    assert_equal( x, l.formatter )

    assert_nil( l.progname )
    l.progname = 'program'
    assert_equal( 'program', l.progname )

    l.close
  end

end
