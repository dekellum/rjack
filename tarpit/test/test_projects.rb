#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

require File.join( File.dirname( __FILE__ ), "setup" )

require 'rjack-tarpit'
require 'fileutils'

class TestProjects < MiniTest::Unit::TestCase
  include FileUtils

  BASEDIR = File.join( File.dirname( __FILE__ ), 'jproject' )


  def setup
    rm_rf( File.join( BASEDIR, 'target' ) )
  end

  def test
    assert( system( "cd #{BASEDIR} && jruby -S rake clean test gem" ) )
  end

end
