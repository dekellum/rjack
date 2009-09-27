#--
# Copyright (C) 2008 David Kellum
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

require 'jetty'

module Jetty

  # Loads testservlets jar.
  module TestServlets
    require File.join( Jetty::JETTY_DIR, "rjack-jetty-1.0.jar" )
    import 'com.gravitext.testservlets.SnoopServlet'
    import 'com.gravitext.testservlets.PerfTestServlet'

    # Webapps directory containing "test/" expanded webapp and "test.war"
    WEBAPPS_DIR = File.join( Jetty::JETTY_DIR, '..', '..', 'webapps' )

    WEBAPP_TEST_EXPANDED = File.join( WEBAPPS_DIR, 'test' )
    WEBAPP_TEST_WAR      = File.join( WEBAPPS_DIR, 'test.war' )
  end
end
