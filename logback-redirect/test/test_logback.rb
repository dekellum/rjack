#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2008-2011 David Kellum
#
# rjack-logback is free software: you can redistribute it and/or
# modify it under the terms of either of following licenses:
#
#   GNU Lesser General Public License v3 or later
#   Eclipse Public License v1.0
#
# rjack-logback is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#++

$LOAD_PATH.unshift File.join( File.dirname(__FILE__), "..", "lib" )
require 'logback'

# Test load works
require 'logback/access'

require 'test/unit'

class TestLogback < Test::Unit::TestCase

  def test_output
    Logback.config_console
    log = RJack::SLF4J[ "my.app" ]
    log.info( "test output" )
    assert true
  end

end
