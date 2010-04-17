#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (C) 2009 David Kellum
#
# See README.rdoc for license terms.
#++

require 'java'
require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift File.join( File.dirname(__FILE__), "..", "lib" )

require 'rjack-jdom'

class TestJdom < Test::Unit::TestCase

  import 'org.jdom.Element'
  import 'org.jdom.Document'
  import 'org.jdom.output.XMLOutputter'

  def test_output
    doc = Document.new( Element.new( "document" ) )
    assert( XMLOutputter.new.outputString( doc ) =~ /<document/ )
  end
end
