#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived
#--
# Copyright (C) 2008 David Kellum
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

TEST_DIR = File.dirname(__FILE__)

$LOAD_PATH.unshift File.join( TEST_DIR, "..", "lib" )

require 'rubygems'

# Disable jetty logging if slf4j is available
begin
  gem( 'slf4j', '~> 1.5' )
  require 'slf4j'
  require 'slf4j/nop'
rescue Gem::LoadError
end

require 'jetty'
require 'jetty/test-servlets'
require 'test/unit'
require 'net/http'

class TestJetty < Test::Unit::TestCase

  def default_factory
    factory = Jetty::ServerFactory.new
    factory.max_threads = 1
    factory.stop_at_shutdown = false
    factory
  end

  def test_start_stop
    10.times do
      factory = default_factory
      factory.static_contexts[ '/' ] = TEST_DIR
      server = factory.create
      server.start
      assert( server.is_started )
      assert( server.connectors[0].local_port > 0 )
      server.stop
      assert( server.is_stopped )
    end
  end

  def test_static_context
    factory = default_factory
    factory.static_contexts[ '/' ] = TEST_DIR
    server = factory.create
    server.start
    port = server.connectors[0].local_port
    test_text = Net::HTTP.get( 'localhost', '/test.txt', port )
    assert_equal( File.read( File.join( TEST_DIR, 'test.txt' ) ), test_text )
    server.stop
  end

  import 'org.mortbay.jetty.handler.AbstractHandler'
  class TestHandler < AbstractHandler
    TEST_TEXT = 'test handler text'

    def handle( target, request, response, dispatch )
      response.content_type = "text/plain"
      response.writer.write( TEST_TEXT )
      request.handled = true
    end
  end

  def test_custom_handler
    factory = default_factory
    def factory.create_pre_handlers
      super << TestHandler.new
    end
    server = factory.create
    server.start
    port = server.connectors[0].local_port
    assert_equal( TestHandler::TEST_TEXT,
                  Net::HTTP.get( 'localhost', '/whatever', port ) )
    server.stop
  end

  import 'javax.servlet.http.HttpServlet'
  class TestServlet < HttpServlet
    def initialize( text )
      super()
      @text = text
    end

    def doGet( request, response )
      response.content_type = "text/plain"
      response.writer.write( @text )
    end
  end

  def test_servlet_handler
    factory = default_factory
    factory.set_context_servlets( '/some',
      { '/test'  => TestServlet.new( 'resp-test' ),
        '/other' => TestServlet.new( 'resp-other' ) } )

    factory.set_context_servlets( '/',
      { '/one' => TestServlet.new( 'resp-one' ),
        '/snoop' => Jetty::TestServlets::SnoopServlet.new } )

    server = factory.create
    server.start
    port = server.connectors[0].local_port

    assert_equal( 'resp-test',
                  Net::HTTP.get( 'localhost', '/some/test', port ) )
    assert_equal( 'resp-other',
                  Net::HTTP.get( 'localhost', '/some/other', port ) )
    assert_equal( 'resp-one',
                  Net::HTTP.get( 'localhost', '/one', port ) )

    response = Net::HTTP.get_response( 'localhost', '/', port )
    assert( response.is_a?( Net::HTTPNotFound ) )

    response = Net::HTTP.get_response( 'localhost', '/snoop', port )
    assert( response.is_a?( Net::HTTPSuccess ) )

    server.stop
  end

  def test_webapp
    factory = default_factory
    index_html = File.read(
      File.join( Jetty::TestServlets::WEBAPP_TEST_EXPANDED, 'index.html' ) )

    factory.webapp_contexts[ '/test' ]     = Jetty::TestServlets::WEBAPP_TEST_WAR
    factory.webapp_contexts[ '/expanded' ] = Jetty::TestServlets::WEBAPP_TEST_EXPANDED

    server = factory.create
    server.start
    port = server.connectors[0].local_port

    assert_equal( index_html, Net::HTTP.get( 'localhost', '/test/', port ) )
    assert_equal( index_html, Net::HTTP.get( 'localhost', '/expanded/', port ) )

    response = Net::HTTP.get_response( 'localhost', '/test/snoop/info?i=33', port )
    assert( response.is_a?( Net::HTTPSuccess ) )

    server.stop
  end
end
