#--
# Copyright (C) 2009 David Kellum
#
# See README.rdoc for license terms.
#++

module RJack
  module JDOM

    # JDOM (java) version
    # Note a jdom 1.1.1 preview is available (not yet in maven)
    JDOM_VERSION = '1.1'

    # rjack gem version (reserve one more decimal for jdom itself)
    VERSION = JDOM_VERSION + '.0.1'

    JDOM_DIR = File.dirname( __FILE__ ) # :nodoc:
  end
end
