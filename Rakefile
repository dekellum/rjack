# -*- ruby -*-
#--
# Copyright (C) 2008 David Kellum
#
# Logback Ruby is free software: you can redistribute it and/or
# modify it under the terms of the 
# {GNU Lesser General Public License}[http://www.gnu.org/licenses/lgpl.html] 
# as published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Logback Ruby is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#++

require 'rubygems'

ENV['NODOT'] = "no thank you"
require 'hoe'

$LOAD_PATH << './lib'
require 'jetty/base'
Jetty = JettyBase

JARS = %w{ jetty jetty-util jetty-rewrite-handler }.map do |n| 
  "#{n}-#{ Jetty::JETTY_VERSION }.jar" 
end
JARS << "servlet-api-#{ Jetty::SERVLET_API_VERSION }-#{ Jetty::JETTY_VERSION }.jar"
JARS << 'gravitext-testservlets-1.0.jar'
JAR_FILES = JARS.map { |jar| "lib/jetty/#{jar}" }


desc "Update the Manifest with actual jars"
task :manifest do
  out = File.new( 'Manifest.txt', 'w' ) 
  begin
    out.write <<END
History.txt
Manifest.txt
README.txt
Rakefile
pom.xml
assembly.xml
bin/jetty-service
lib/jetty.rb
lib/jetty/base.rb
lib/jetty/rewrite.rb
lib/jetty/test-servlets.rb
test/test_jetty.rb
webapps/test/index.html
webapps/test/WEB-INF/web.xml
webapps/test.war
END
    out.puts JAR_FILES
  ensure
    out.close
  end
end

ASSEMBLY = "target/gravitext-testservlets-1.0-bin.dir"

file 'webapps/test.war' => [ 'webapps/test/index.html', 
                             'webapps/test/WEB-INF/web.xml' ] do
  sh( 'jar cvf webapps/test.war -C webapps/test .' )
end

file ASSEMBLY => [ 'pom.xml', 'assembly.xml' ] do
  sh( 'mvn package' )
end

JARS.each do |jar|
  file "lib/jetty/#{jar}" => [ ASSEMBLY ] do
    cp_r( File.join( ASSEMBLY, jar ), 'lib/jetty' )
  end
end

[ :gem, :test ].each { |t| task t => JAR_FILES }

task :mvn_clean do
  rm_f( JAR_FILES )
  sh( 'mvn clean' )
end
task :clean => :mvn_clean 

hoe = Hoe.new( "jetty", Jetty::VERSION ) do |p|
  p.developer( "David Kellum", "dek-ruby@gravitext.com" )
  p.rubyforge_name = "rjack"
  p.rdoc_pattern = /^(lib.*\.(rb|txt))|[^\/]*\.txt$/
end
