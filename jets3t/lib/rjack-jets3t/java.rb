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

require 'java'

require 'rjack-slf4j'
require 'rjack-slf4j/jcl-over-slf4j'
require 'rjack-commons-codec'
require 'rjack-httpclient-4'
require 'rjack-jets3t/base'

module RJack::JetS3t
  Dir.glob( File.join( JETS3T_DIR, '*.jar' ) ).each { |jar| require jar }

  import 'org.jets3t.service.S3ServiceException'

  #Alias to org.jets3t.service.model.S3Bucket
  JS3Bucket = Java::org.jets3t.service.model.S3Bucket
end
