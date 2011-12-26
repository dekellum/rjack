#!/usr/bin/env jruby
#. hashdot.profile += jruby-shortlived
#. jruby.launch.inproc = false

require File.join( File.dirname( __FILE__ ), "setup" )

require 'rjack-tarpit'
require 'fileutils'

class TestProjects < MiniTest::Unit::TestCase
  include FileUtils

  BASEDIR = File.dirname( __FILE__ )

  def path( *args )
    File.join( BASEDIR, *args )
  end

  def setup
    # We clean anyway, but for test consistency...
    %w[ jproject zookeeper ].each do |p|
      rm_rf( path( p, 'target' ) )
      rm_rf( path( p, 'pkg' ) )
    end
  end

  def test_jproject
    Dir.chdir( path( 'jproject' ) ) do
      assert runv( "clean test gem" )
    end
  end

  def test_zookeeper
    Dir.chdir( path( 'zookeeper' ) ) do
      assert runv( "manifest" )
      assert runv( "clean test gem" )
    end
  end

  def runv( targets )
    c = "jruby -S rake #{targets}"
    puts
    puts "=== #{Dir.pwd} > #{c} ==="
    # Disable seemingly lame bundler ENV mods to make these tests work
    # the same as if we ran it in our own shell.
    r = Bundler.with_clean_env { system( c ) }
    puts
    r
  end

end
