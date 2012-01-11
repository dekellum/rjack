#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2009-2011 David Kellum
#
# See README.rdoc for license terms.
#++

require 'rubygems'
require 'bundler/setup'

require 'rjack-logback'

RJack::Logback.config_console( :level => RJack::Logback::DEBUG )
if ARGV.include?( '-v' ) || ARGV.include?( '--verbose' )
  RJack::Logback.root.level = RJack::Logback::DEBUG
end

require 'minitest/unit'
require 'minitest/autorun'

require 'rjack-jdom'

class TestJdom < MiniTest::Unit::TestCase

  import 'org.jdom.Element'
  import 'org.jdom.Document'
  import 'org.jdom.output.XMLOutputter'

  def test_output
    doc = Document.new( Element.new( "document" ) )
    assert( XMLOutputter.new.outputString( doc ) =~ /<document/ )
  end
end
