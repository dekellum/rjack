#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived
#--
# Copyright (c) 2009-2013 David Kellum
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You
# may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#++

require File.join( File.dirname( __FILE__ ), "setup" )

require 'rjack-tarpit/readme_parser'

require 'stringio'

class TestReadmeParser < MiniTest::Unit::TestCase
  include RJack::TarPit::ReadmeParser

  attr_accessor :summary
  attr_accessor :description
  attr_accessor :homepage

  def test_one_liner
    self.desc = <<TXT
A gem packaging of {Marble Bread}[http://special/marble-bread/]
TXT
    parse_readme( nil )

    assert_equal( "http://rjack.rubyforge.org/foo", homepage )
    assert_equal( "A gem packaging of Marble Bread", summary )
    assert_nil( description )
  end

  def test_one_line_punct
    self.desc = <<TXT
A gem packaging of Marbles[http://special/marbles/].
TXT
    parse_readme( nil )

    assert_equal( "A gem packaging of Marbles.", summary )
    assert_nil( description )
  end

  def test_two_sentences
    self.desc = <<TXT
A gem packaging of Marbles!
Highly valued!
TXT
    parse_readme( nil )

    assert_equal( "A gem packaging of Marbles!", summary )
    assert_equal( "A gem packaging of Marbles! Highly valued!", description )
  end

  def test_colon
    self.desc = <<TXT
A gem packaging of special sauces:

* Mustard
* Honey
TXT
    parse_readme( nil )

    assert_equal( "A gem packaging of special sauces.", summary )
    assert_nil( description )
  end

  def readme_file_open( file )
    yield StringIO.new( @test_readme_input )
  end

  def desc=( desc )
    @test_readme_input = <<RDOC
= name

* http://rjack.rubyforge.org/foo
* http://rjack.rubyforge.org/other

== Description

#{desc}

== License
RDOC

  end

end
