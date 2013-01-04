#--
# Copyright (c) 2008-2013 David Kellum
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++

require 'rjack-slf4j'
require 'java'

# Utilities for finer grain control of the JDK java.util.logging
# (JUL). In particular, unlike other logging API's reimplemented by
# slf4j adapters, JUL log levels remain significant for enabling output
# or avoiding log message generation cycles. For a particular
# level to be output, both JUL and the destination SLF4J output adapter
# must enable it.
#
# == Usage
#
# Adjust JUL levels (in conjunction with 'slf4j/jul-to-slf4j' or
# 'slf4j/jdk14', see SLF4J.)
#
#   require 'rjack-slf4j/jul'
#   SLF4J::JUL[ "my.jul.logger" ].level = SLF4J::JUL::FINER
#
# Direct all output to SLF4J (output adapter != 'jdk14')
#
#   require 'rjack-slf4j/jul-to-slf4j'
#   RJack::SLF4J::JUL.replace_root_handlers
#
module RJack::SLF4J::JUL
  LogManager         = Java::java.util.logging.LogManager
  Logger             = Java::java.util.logging.Logger
  Level              = Java::java.util.logging.Level

  SEVERE  = Level::SEVERE
  WARNING = Level::WARNING
  INFO    = Level::INFO
  CONFIG  = Level::CONFIG
  FINE    = Level::FINE
  FINER   = Level::FINER
  FINEST  = Level::FINEST
  ALL     = Level::ALL

  # Global java.util.logging.LogManager reset: close any handlers and
  # set root level to INFO.
  def self.reset
    LogManager.log_manager.reset
  end

  # Get java.util.logging.Logger by name (responds to level=, etc.)
  def self.[]( name )
    Logger.get_logger( name )
  end

  # Get the root logger (empty string name)
  def self.root
    Logger.get_logger( "" )
  end
end
