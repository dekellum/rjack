#!/usr/bin/env jruby

#--
# Copyright (C) 2009 David Kellum
#
# See README.rdoc for license terms.
#++

require 'rubygems'

require 'test/unit'

$LOAD_PATH.unshift File.join( File.dirname(__FILE__), "..", "lib" )

require 'rjack-jdom'

class TestJdom < Test::Unit::TestCase

  def test_setup
    assert true # Just confirm we make it here.
  end
end
