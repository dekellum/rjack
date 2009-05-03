= hc-httpclient

* http://rjack.rubyforge.org
* http://rubyforge.org/projects/rjack

== Description

A gem packaging of the {HttpComponents}[http://hc.apache.org/]
(formerly Jakarta Commons) HTTP Client for JRuby.

* Provides commons-httpclient and commons-codec jars.
* Provides a HC::HTTPClient::ManagerFacade for client and connection
  manager setup, start, shutdown.

== Synopsis

 require 'logback'
 require 'hc-httpclient'

 include HC::HTTPClient

 mf = ManagerFacade.new 
 mf.manager_params.max_total_connections = 200
 mf.client_params.so_timeout = 3000 #ms
 mf.start
    
 mf.client # --> org.apache.commons.HttpClient

 mf.shutdown

See {org.apache.commons.HttpClient}[http://hc.apache.org/httpclient-3.x/apidocs/org/apache/commons/httpclient/HttpClient.html].

== Requirements

* slf4j[http://rjack.rubyforge.org/slf4j] (rjack gem).

* An slf4j output adaptor such as 'slf4j/simple' or
  logback[http://rjack.rubyforge.org/logback] must be require'd before
  hc-httpclient.  (The logback gem is listed as a development
  dependency only.)

== License

=== hc-httpclient ruby gem

Copyright (c) 2009 David Kellum

Licensed under the Apache License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License.  You
may obtain a copy of the License at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied.  See the License for the specific language governing
permissions and limitations under the License.

=== Jakarta Commons HTTPClient (java)

Copyright (c) 1999-2007 The Apache Software Foundation

Licensed to the Apache Software Foundation (ASF) under one or more
contributor license agreements.  See the NOTICE file distributed with
this work for additional information regarding copyright ownership.
The ASF licenses this file to You under the Apache License, Version
2.0 (the "License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied.  See the License for the specific language governing
permissions and limitations under the License.
