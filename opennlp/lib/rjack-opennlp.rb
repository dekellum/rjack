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

require 'rjack-opennlp/base'
require 'java'

module RJack::OpenNLP
  Dir.glob( File.join( LIB_DIR, '*.jar' ) ).each { |jar| require jar }

  import 'opennlp.tools.sentdetect.SentenceModel'
  import 'opennlp.tools.sentdetect.SentenceDetectorME'

  MODELS_DIR = File.expand_path( '../../models', __FILE__ )

  module_function

  # Load the sentence model for the specified language (if available)
  # Raises java.io.IOException on read error
  def load_sentence_model( lang = 'en' )
    input =
      Java::java.io.FileInputStream.new( "#{MODELS_DIR}/#{lang}-sent.bin" )
    SentenceModel.new( input )
  ensure
    input.close if input
  end

end
