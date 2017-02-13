#--
# Copyright (c) 2009-2017 David Kellum
#
# See README.rdoc for license terms.
#++

require 'rjack-jdom/base'
require 'java'

# JDOM wrapper module
module RJack
  module JDOM
    require "#{JDOM_DIR}/jdom-#{JDOM_VERSION}.jar"
  end
end
