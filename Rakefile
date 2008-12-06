# -*- ruby -*-
#--
# Copyright (C) 2008 David Kellum
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You
# may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#++

require 'rubygems'

ENV['NODOT'] = "no thank you"
require 'hoe'

$LOAD_PATH << './lib'
require 'jetty/base'

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
src/main/java/com/gravitext/testservlets/PerfTestServlet.java
src/main/java/com/gravitext/testservlets/SnoopServlet.java
test/test_jetty.rb
test/test.txt
webapps/test.war
webapps/test/WEB-INF/web.xml
webapps/test/index.html
END
    out.puts JAR_FILES
  ensure
    out.close
  end
end

ASSEMBLY = "target/gravitext-testservlets-1.0-bin.dir"

file 'webapps/test.war' => [ 'webapps/test/index.html', 
                             'webapps/test/WEB-INF/web.xml' ] do
  sh( 'jar cvf webapps/test.war ' + 
      '-C webapps/test index.html -C webapps/test WEB-INF/web.xml' )
end

file ASSEMBLY => [ 'pom.xml', 'assembly.xml' ] do
  sh( 'mvn package' )
end

JARS.each do |jar|
  file "lib/jetty/#{jar}" => [ ASSEMBLY ] do
    cp_r( File.join( ASSEMBLY, jar ), 'lib/jetty' )
  end
end

[ :gem, :test ].each { |t| task t => JAR_FILES + [ 'webapps/test.war' ] }

task :mvn_clean do
  rm_f( JAR_FILES + [ 'webapps/test.war' ] )
  sh( 'mvn clean' )
end
task :clean => :mvn_clean 

task :tag do
  tag = "jetty-#{Jetty::VERSION}"
  svn_base = 'svn://localhost/subversion.repo/src/gems'
  tag_url = "#{svn_base}/tags/#{tag}"

  dname = File.dirname( __FILE__ )
  dname = '.' if Dir.getwd == dname
  stat = `svn status #{dname}`
  stat.strip! if stat
  if ( stat && stat.length > 0 )
    $stderr.puts( "Resolve the following before tagging (svn status):" )
    $stderr.puts( stat )
  else
    sh( "svn cp -m 'tag [#{tag}]' #{dname} #{tag_url}" )
  end
end

hoe = Hoe.new( "jetty", Jetty::VERSION ) do |p|
  p.developer( "David Kellum", "dek-ruby@gravitext.com" )
  p.rubyforge_name = "rjack"
  p.rdoc_pattern = /^(lib.*\.(rb|txt))|[^\/]*\.txt$/
end
