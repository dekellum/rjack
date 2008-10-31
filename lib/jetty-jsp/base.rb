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

module JettyJspBase
  JETTY_VERSION = '6.1.11'
  JSP_VERSION = '2.1'
  GEM_VERSION = '1'

  VERSION = [ JETTY_VERSION, JSP_VERSION, GEM_VERSION ].join('.') # = 6.1.11.2.1.1

  JETTY_JSP_DIR = File.dirname(__FILE__) # :nodoc:
end
