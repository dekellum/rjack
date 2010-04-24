#--
# Copyright (c) 2008-2010 David Kellum
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

module RJack
  module Jetty
    module Jsp
      JETTY_VERSION = '6.1.24'
      JSP_VERSION = '2.1'
      GEM_VERSION = '0'

      VERSION = [ JETTY_VERSION, JSP_VERSION, GEM_VERSION ].join( '.' )

      JETTY_JSP_DIR = File.dirname( __FILE__ ) # :nodoc:
    end
  end
end
