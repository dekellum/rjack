#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2008-2017 David Kellum
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

require 'rubygems'
require 'bundler/setup'

# Disable Jetty Logging
require 'rjack-slf4j'
require 'rjack-slf4j/nop'

require 'minitest/unit'
require 'minitest/autorun'

require 'rjack-jetty'

require 'rjack-jetty/client'
require 'rjack-jetty/rewrite'
require 'rjack-jetty/test-servlets'

require 'net/http'
require 'openssl'

class TestJetty < MiniTest::Unit::TestCase
  include RJack::Jetty

  TEST_DIR = File.dirname(__FILE__)

  def default_factory
    factory = ServerFactory.new
    factory.max_threads = 1
    factory.stop_at_shutdown = false
    factory
  end

  def test_parse_inherit_channel
    factory = default_factory
    factory.connections = [ 'tcp://127.0.0.1?inherit_channel=true',
                            { scheme: 'tcp', inherit_channel: true },
                            'tcp://127.0.0.1?inherit_channel=false',
                            { scheme: 'tcp', inherit_channel: false },
                            'tcp://127.0.0.1?inherit_channel=nil',
                            { scheme: 'tcp', inherit_channel: nil } ]
    server = factory.create
    connectors = server.connectors
    assert( connectors[0].inherit_channel )
    assert( connectors[1].inherit_channel )
    assert( !connectors[2].inherit_channel )
    assert( !connectors[3].inherit_channel )
    assert( !connectors[4].inherit_channel )
    assert( !connectors[5].inherit_channel )
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
      server.join
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
    server.join
  end

  def test_static_ssl
    factory = default_factory
    factory.connections = [ { scheme: 'tcp' },
                            { scheme: 'ssl',
                              key_store_path: 'test/keystore',
                              key_store_password: 'password'} ]
    factory.static_contexts[ '/' ] = TEST_DIR
    server = factory.create
    server.start
    port = server.connectors[1].local_port
    test_text = get( '/test.txt', port, :ssl ).body
    assert_equal( File.read( File.join( TEST_DIR, 'test.txt' ) ), test_text )
    server.stop
    server.join
  end

  def test_static_ssl_uri
    factory = default_factory
    factory.connections = [ 'tcp://0.0.0.0',
                            'ssl://127.0.0.1?key_store_path=test/keystore&key_store_password=password' ]
    factory.static_contexts[ '/' ] = TEST_DIR
    server = factory.create
    server.start
    port = server.connectors[1].local_port
    test_text = get( '/test.txt', port, :ssl ).body
    assert_equal( File.read( File.join( TEST_DIR, 'test.txt' ) ), test_text )
    server.stop
    server.join
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
    server.join
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
      { '/one'   => TestServlet.new( 'resp-one' ),
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
    server.join
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
    server.join
  end

  def get( path, port, scheme = :tcp )
    args = [ 'localhost', port, nil, nil, nil, nil ]
    if scheme == :ssl
      args << { use_ssl: true,
                # From https://wiki.mozilla.org/Security/Server_Side_TLS (intermediate)
                ciphers: "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA",
                verify_mode: OpenSSL::SSL::VERIFY_NONE }
    end
    Net::HTTP.start( *args ) do |http|
      http.open_timeout = 1.0
      http.read_timeout = 1.0
      http.get( path )
    end
  end

end
