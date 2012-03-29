#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2012 David Kellum
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

require 'rjack-opennlp'

class TestOpenNLP < MiniTest::Unit::TestCase
  include RJack::OpenNLP

  def test_load
    refute_nil( load_sentence_model )
  end

  def test_sent_detect
    model = load_sentence_model
    detector = SentenceDetectorME.new( model )
    sentences = [ "Sentence one.",
                  "Sentence two." ]
    assert_equal( sentences,
                  detector.sent_detect( sentences.join( '  ' ) ).to_a )
  end

  def test_sent_position_detect
    model = load_sentence_model
    detector = SentenceDetectorME.new( model )
    input = "First one.  Second one."
    spans = detector.sent_pos_detect( input ).to_a
    assert_equal( 2, spans.length )
    s = spans[0]
    assert_equal( "First one.", input[s.start, s.end] )
    s = spans[1]
    assert_equal( "Second one.", input[s.start, s.end] )
  end

  def test_load_error
    load_sentence_model( 'ru' )
    flunk "No error for missing model"
  rescue NativeException => e
    assert_kind_of( Java::java.io.FileNotFoundException, e.cause )
  end

end
