#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

require File.join( File.dirname( __FILE__ ), "setup" )

require 'jproject'

class TestJProject < MiniTest::Unit::TestCase

  def test_load
    assert_equal( "Hello", JProject::Sample.hello )
  end

end
