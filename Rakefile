# -*- ruby -*-

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
History.txt
Manifest.txt
README.txt
Rakefile
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
  p.developer( "David Kellum", "dek-gem@gravitext.com" )
end
