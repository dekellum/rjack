#--
# Copyright (C) 2008 David Kellum
#
# Logback Ruby is free software: you can redistribute it and/or
# modify it under the terms of the 
# {GNU Lesser General Public License}[http://www.gnu.org/licenses/lgpl.html] 
# as published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Logback Ruby is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#++

require 'jetty'

module Jetty
  module TestServlets
     require File.join( Jetty::JETTY_DIR, "gravitext-testservlets-1.0.jar" )

     # Webapps directory containing "test/" expanded webapp and "test.war"
     WEBAPPS_DIR = File.join( Jetty::JETTY_DIR, '..', '..', 'webapps' )

     WEBAPP_TEST_EXPANDED = File.join( WEBAPPS_DIR, 'test' )
     WEBAPP_TEST_WAR      = File.join( WEBAPPS_DIR, 'test.war' )
  end
end
