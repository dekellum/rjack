#--
# Copyright (c) 2008-2013 David Kellum
# All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'rjack-slf4j'
require 'rjack-slf4j/jul'

RJack::SLF4J.require_adapter( 'jul-to-slf4j' )

module RJack::SLF4J::JUL

  # Replace any existing configured root java.util.Logger Handlers with
  # the org.slf4j.bridge.SLF4JBridgeHandler
  def self.replace_root_handlers
    root_logger = root
    root_logger.handlers.each do |handler|
      root_logger.remove_handler( handler )
    end
    handler = Java::org.slf4j.bridge.SLF4JBridgeHandler.new

    root_logger.add_handler( handler )
  end

end
