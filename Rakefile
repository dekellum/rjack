# -*- ruby -*-
#--
# Copyright (c) 2008 David Kellum
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

require 'rubygems'
require 'hoe'

$LOAD_PATH << './lib'

require 'slf4j/version' 
# Instead of 'slf4j' to avoid loading slf4j-api in Rake parent loader

LOADERS = SLF4J::ADAPTERS.flatten.compact
LOADER_FILES = LOADERS.map { |adp| "lib/slf4j/#{adp}.rb" }

jars = [ 'slf4j-api' ]
jars += SLF4J::ADAPTERS.map { |i,o| [ i, "slf4j-#{o}" ] }.flatten.compact
jars.map! { |n| "#{n}-#{SLF4J::SLF4J_VERSION}.jar" }

JARS = jars

JAR_FILES = JARS.map { |jar| "lib/slf4j/#{jar}" }

desc "Update the Manifest with actual jars/loaders"
task :manifest do
  out = File.new( 'Manifest.txt', 'w' ) 
  begin
    out.write <<END
Manifest.txt
README.txt
History.txt
Rakefile
pom.xml
assembly.xml
lib/slf4j.rb
lib/slf4j/version.rb
test/test_slf4j.rb
END
    out.puts LOADER_FILES
    out.puts JAR_FILES
  ensure
    out.close
  end
end

LOADERS.each do |adapter| 
  file "lib/slf4j/#{adapter}.rb" do
    out = File.new( "lib/slf4j/#{adapter}.rb", 'w' )
    begin
      out.puts "SLF4J.require_adapter( '#{adapter}' )"
    ensure
      out.close
    end
  end
end

ASSEMBLY = "target/slf4j-assembly-1.0-bin.dir"

file ASSEMBLY => [ 'pom.xml', 'assembly.xml' ] do
  sh( 'mvn package' )
end

JARS.each do |jar|
  file "lib/slf4j/#{jar}" => [ ASSEMBLY ] do
    cp_r( File.join( ASSEMBLY, jar ), 'lib/slf4j' )
  end
end

[ :gem, :test ].each { |t| task t => ( JAR_FILES + LOADER_FILES ) }

task :mvn_clean do
  rm_f( JAR_FILES )
  rm_f( LOADER_FILES )
  sh( 'mvn clean' )
end
task :clean => :mvn_clean 

hoe = Hoe.new( "slf4j", SLF4J::VERSION ) do |p|
  p.developer( "David Kellum", "dek-ruby@gravitext.com" )
end
