#--
# Copyright (C) 2008-2009 David Kellum
#
# rjack-logback is free software: you can redistribute it and/or
# modify it under the terms of either of following licenses:
#
#   GNU Lesser General Public License v3 or later
#   Eclipse Public License v1.0
#
# rjack-logback is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
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
