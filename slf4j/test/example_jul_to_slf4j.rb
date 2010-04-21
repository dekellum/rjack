#!/usr/bin/env jruby
#--
# Copyright (c) 2008-2010 David Kellum
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

$LOAD_PATH.unshift File.join( File.dirname(__FILE__), "..", "lib" )

require 'rjack-slf4j/jul-to-slf4j'

# FIXME: Can't make this a standard test case, as test_slf4j.rb uses
# slf4j/jdk14 output adapter.

SLF4J::JUL.replace_root_handlers
SLF4J::JUL.root.level = SLF4J::JUL::INFO

julog = SLF4J::JUL[ "jul" ]
julog.level = SLF4J::JUL::FINEST

require 'rubygems'
require 'rjack-logback'
Logback.root.level = Logback::TRACE

slog = SLF4J['slf4j']
slog.debug "from slf4j"

julog.info( "INFO message" )
julog.finer( "FINER message" )
julog.finest( "FINEST message" )
