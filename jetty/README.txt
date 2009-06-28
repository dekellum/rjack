= jetty

* http://rjack.rubyforge.org
* http://rubyforge.org/projects/rjack

== Description

A gem packaging of the {Jetty Web Server}[http://www.mortbay.org/jetty/]
for JRuby:

* Provides jetty, jetty-util, servlet-api, and jetty-rewrite-handler
  jars.
* A Jetty::ServerFactory for simple programmatic server setup in ruby.
* A set of Jetty::TestServlets containing a SnoopServlet and
  PerfTestServlet (implemented in Java).
* A jetty-service bin script for easy testing from the command line.

Note that JSP support is provided separately in the companion
jetty-jsp[http://rjack.rubyforge.org/jetty-jsp/] gem.

== Synopsis

  % jetty-service -v
  Usage: jetty-service [options]
      -p, --port N           Port to listen on (default: auto)
      -t, --threads N        Maximum pool threads (default: 20)
      -w, --webapp PATH      Load PATH as root context webapp
                             (default: gem test.war)
      -j, --jsp              Enable JSP support by loading jetty-jsp gem
      -d, --debug            Enable debug logging
      -v, --version          Show version and exit

or

  require 'jetty'
  require 'jetty/test-servlets'

  factory = Jetty::ServerFactory.new
  factory.port = 8080

  factory.set_context_servlets( '/', '/*' => Jetty::TestServlets::SnoopServlet.new )
  server = factory.create
  server.start
  server.join

== Requirements

No hard requirements, however:

* To load webapps with JSPs, the jetty-jsp[http://rjack.rubyforge.org/jetty-jsp/]
  gem must be loaded.
* Jetty will log to slf4j[http://rjack.rubyforge.org/slf4j] if
  loaded. The jetty-service script will attempt to load
  logback[http://rjack.rubyforge.org/logback], and thus slf4j, if
  available.

== License

=== jetty ruby gem, test servlets

Copyright (c) 2008-2009 David Kellum

Licensed under the Apache License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License.  You
may obtain a copy of the License at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied.  See the License for the specific language governing
permissions and limitations under the License.

=== Jetty Web Container (Java)

Copyright (c) 1995-2006 Mort Bay Consulting Pty Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

The Jetty Web Container is Copyright Mort Bay Consulting Pty Ltd
unless otherwise noted. It is licensed under the apache 2.0
license.

The javax.servlet package used by Jetty is copyright
Sun Microsystems, Inc and Apache Software Foundation. It is
distributed under the Common Development and Distribution License.
You can obtain a copy of the license at
https://glassfish.dev.java.net/public/CDDLv1.0.html.

The UnixCrypt.java code ~Implements the one way cryptography used by
Unix systems for simple password protection.  Copyright 1996 Aki Yoshida,
modified April 2001  by Iris Van den Broeke, Daniel Deville.
Permission to use, copy, modify and distribute UnixCrypt
for non-commercial or commercial purposes and without fee is
granted provided that the copyright notice appears in all copies.

The default JSP implementation is provided by the Glassfish JSP engine
from project Glassfish http://glassfish.dev.java.net.  Copyright 2005
Sun Microsystems, Inc. and portions Copyright Apache Software Foundation.

Some portions of the code are Copyright:
  2006 Tim Vernum
  1999 Jason Gilbert.

The jboss integration module contains some LGPL code.
