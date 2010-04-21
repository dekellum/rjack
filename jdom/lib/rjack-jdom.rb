#--
# Copyright (C) 2009 David Kellum
#
# See README.rdoc for license terms.
#++

require 'rjack-jdom/base'

# JDOM wrapper module
module RJack
  module JDOM
    require "#{JDOM_DIR}/jdom-#{JDOM_VERSION}.jar"
  end
end
