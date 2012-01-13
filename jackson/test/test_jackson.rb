#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2011-2012 David Kellum
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

require 'rubygems'
require 'bundler/setup'

require 'minitest/unit'
require 'minitest/autorun'

require 'rjack-jackson'

require 'rjack-jackson/jaxrs'
require 'rjack-jackson/xc'

class TestJackson < MiniTest::Unit::TestCase
  include RJack

  import 'org.codehaus.jackson.JsonParser'

  import 'org.codehaus.jackson.jaxrs.MapperConfigurator'       #jaxrs
  import 'org.codehaus.jackson.xc.DataHandlerJsonDeserializer' #xc

  def test_load
    pass
  end
end
