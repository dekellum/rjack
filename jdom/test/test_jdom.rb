#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2009-2014 David Kellum
#
# See README.rdoc for license terms.
#++

require 'rubygems'
require 'bundler/setup'

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
