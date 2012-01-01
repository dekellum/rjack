#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

require File.join( File.dirname( __FILE__ ), "setup" )

require 'rjack-maven'

class TestMaven < MiniTest::Unit::TestCase

  def test_launch
    assert_equal( 0, RJack::Maven.launch( %w[ -v ] ) )
  end

end
