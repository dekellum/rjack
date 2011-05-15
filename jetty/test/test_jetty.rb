#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived
#--
# Copyright (c) 2008-2011 David Kellum
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

# Disable jetty logging if rjack-slf4j is available
begin
  gem( 'rjack-slf4j', '~> 1.5' )
  require 'rjack-slf4j'
  require 'rjack-slf4j/nop'
rescue Gem::LoadError
end

require 'rjack-jetty'
require 'rjack-jetty/test-servlets'
require 'test/unit'
require 'net/http'

class TestJetty < Test::Unit::TestCase
  include RJack::Jetty

  def default_factory
    factory = ServerFactory.new
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
    test_text = get( '/test.txt', port ).body
    assert_equal( File.read( File.join( TEST_DIR, 'test.txt' ) ), test_text )
    server.stop
  end

  class TestHandler < AbstractHandler
    TEST_TEXT = 'test handler text'

    def handle( target, base_request, request, response )
      response.content_type = "text/plain"
      response.writer.write( TEST_TEXT )
      base_request.handled = true
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
    resp = get( '/whatever', port )
    assert_equal( TestHandler::TEST_TEXT, resp.body )
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
        '/snoop' => TestServlets::SnoopServlet.new } )

    server = factory.create
    server.start
    port = server.connectors[0].local_port

    assert_equal( 'resp-test',  get( '/some/test', port ).body )
    assert_equal( 'resp-other', get( '/some/other', port ).body )
    assert_equal( 'resp-one',   get( '/one', port ).body )

    assert( get( '/', port ).is_a?( Net::HTTPNotFound ) )

    assert( get( '/snoop', port ).is_a?( Net::HTTPSuccess ) )

    server.stop
  end

  def test_webapp
    factory = default_factory
    index_html = File.read(
      File.join( TestServlets::WEBAPP_TEST_EXPANDED, 'index.html' ) )

    factory.webapp_contexts[ '/test' ]     = TestServlets::WEBAPP_TEST_WAR
    factory.webapp_contexts[ '/expanded' ] = TestServlets::WEBAPP_TEST_EXPANDED

    server = factory.create
    server.start
    port = server.connectors[0].local_port

    assert_equal( index_html, get( '/test/', port ).body )
    assert_equal( index_html, get( '/expanded/', port ).body )

    assert( get( '/test/snoop/info?i=33', port ).is_a?( Net::HTTPSuccess ) )

    server.stop
  end

  def get( path, port )
    Net::HTTP.start( 'localhost', port ) do |http|
      http.open_timeout = 1.0
      http.read_timeout = 1.0
      http.get( path )
    end
  end

end
