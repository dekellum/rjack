#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

require File.join( File.dirname( __FILE__ ), "setup" )

require 'rjack-zookeeper'

class TestZooKeeper < MiniTest::Unit::TestCase

  def test
    pass #FIXME
  end

end
