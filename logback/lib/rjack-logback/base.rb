#--
# Copyright (C) 2008-2009 David Kellum
#
# rjack-logback is free software: you can redistribute it and/or
# modify it under the terms of the
# {GNU Lesser General Public License}[http://www.gnu.org/licenses/lgpl.html]
# as published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# rjack-logback is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#++

module RJack
  module Logback
    # Logback java version
    LOGBACK_VERSION = '0.9.18'

    # Logback gem version
    VERSION = LOGBACK_VERSION + '.0'

    LOGBACK_DIR = File.dirname(__FILE__) # :nodoc:
  end
end
