= slf4j

* http://rjack.rubyforge.org
* http://rubyforge.org/projects/rjack

== Description

A JRuby wrapper and gem packaging of the 
{Simple Logging Facade for Java}[http://www.slf4j.org/].  
Provides all jar dependencies and a Ruby Logger compatible
facade.

SLF4J is a java logging abstraction and set of adapters to various
concrete logging implementations and legacy logging APIs.  The SLF4J
gem adds a ruby core Logger compatible facade to SLF4J, and makes any
needed adapters available to JRuby applications. This makes it
possible to unify and control logging output of both java and ruby
components in a JRuby application.

== Features

* The complete set of SLF4J jars with ruby 'require' based selection
  of input and output adapters.
* A Ruby core Logger compatible SLF4J::Logger, allowing ruby code to
  log through SLF4J.

== Synopsis

  require 'slf4j'
  require 'slf4j/simple'

  log = SLF4J.logger( "my.app.logger" )
  log.info { "Hello World!" }

== License

=== slf4j gem 

Copyright (c) 2008 David Kellum
All rights reserved.

The SLF4J ruby wrapper and gem packaging is released under the same
license terms as the SLF4J java source code and binaries, see below. Note
that these license terms are identical to the 
{MIT License}[http://en.wikipedia.org/wiki/MIT_License] and deemed
compatible with GPL and the Apache Software License.

=== SLF4J License

Copyright (c) 2004-2008 QOS.ch 
All rights reserved. 

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

