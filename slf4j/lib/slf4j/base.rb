#--
# Copyright (C) 2008 David Kellum
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

# Base constants for Rakefile, etc.
module SLF4J

  # SLF4J-java version
  SLF4J_VERSION = '1.5.6'
  # SLF4J gem version
  VERSION = SLF4J_VERSION + '.2'

  SLF4J_DIR = File.dirname(__FILE__) # :nodoc:

  #              :input              :output (jar with slf4j- prefix)
  ADAPTERS = [ [ "jul-to-slf4j",     "jdk14"   ],   
               [ "jcl-over-slf4j",   "jcl"     ],
               [ "log4j-over-slf4j", "log4j12" ],
               [ nil,                "nop"     ],
               [ nil,                "simple"  ] ] # :nodoc:
end
