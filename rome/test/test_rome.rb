#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived
#--
# Copyright (c) 2009-2011 David Kellum
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

$LOAD_PATH.unshift File.join( File.dirname(__FILE__), "..", "lib" )

require 'java'
require 'rubygems'
require 'rjack-rome'

require 'test/unit'

include RJack

class TestRome < Test::Unit::TestCase
  import 'com.sun.syndication.feed.synd.SyndFeedImpl'
  def test_me
    assert( true ) #FIXME: Just asserting that the load works for now
  end
end
