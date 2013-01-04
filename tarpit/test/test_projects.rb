#!/usr/bin/env jruby
#. hashdot.profile += jruby-shortlived
#. jruby.launch.inproc = false

#--
# Copyright (c) 2009-2013 David Kellum
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

require File.join( File.dirname( __FILE__ ), "setup" )

require 'rjack-tarpit'
require 'fileutils'

class TestProjects < MiniTest::Unit::TestCase
  include FileUtils

  BASEDIR = File.dirname( __FILE__ )

  if RUBY_PLATFORM =~ /java/

    def setup
      # We clean anyway, but for test consistency...
      %w[ jproject zookeeper ].each do |p|
        rm_rf( path( p, 'target' ) )
        rm_rf( path( p, 'pkg' ) )
      end
    end

    def test_jproject
      pt = path( 'jproject' )
      assert runv( pt, "clean test gem" )
    end

    def test_zookeeper
      pt = path( 'zookeeper' )
      assert runv( pt, "manifest" )
      assert runv( pt, "clean test gem" )
    end

  end

  def path( *args )
    File.join( BASEDIR, *args )
  end

  def runv( dir, targets )
    # Shell cd is most reliabe, given java path duality and potential
    # for jruby to attempt inproc otherwise.
    c = "cd #{dir} && jruby -S rake #{targets}"
    puts
    puts "=== #{c} ==="
    # Disable seemingly lame bundler ENV mods to make these tests work
    # the same as if we ran it in our own shell.
    r = Bundler.with_clean_env { system( c ) }
    puts
    r
  end

end
