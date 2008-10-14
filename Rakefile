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
require 'logback/base'

JARS = %w{ core classic access }.map do |n| 
  "logback-#{n}-#{ LogbackBase::LOGBACK_VERSION }.jar"
end
JAR_FILES = JARS.map { |jar| "lib/logback/#{jar}" }

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
lib/logback.rb
lib/logback/access.rb
lib/logback/base.rb
test/test_logback.rb
END
    out.puts JAR_FILES
  ensure
    out.close
  end
end

ASSEMBLY = "target/logback-assembly-1.0-bin.dir"

file ASSEMBLY => [ 'pom.xml', 'assembly.xml' ] do
  sh( 'mvn package' )
end

JARS.each do |jar|
  file "lib/logback/#{jar}" => [ ASSEMBLY ] do
    cp_r( File.join( ASSEMBLY, jar ), 'lib/logback' )
  end
end

[ :gem, :test ].each { |t| task t => JAR_FILES }

task :mvn_clean do
  rm_f( JAR_FILES )
  sh( 'mvn clean' )
end
task :clean => :mvn_clean 

hoe = Hoe.new( "logback", LogbackBase::VERSION ) do |p|
  p.developer( "David Kellum", "dek-gem@gravitext.com" )
  p.extra_deps << [ 'slf4j', '>=1.5.3.1' ]
  p.rubyforge_name = "rjack"
  p.rdoc_pattern = /^(lib.*\.(rb|txt))|[^\/]*\.txt$/
end
