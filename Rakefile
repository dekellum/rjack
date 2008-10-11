# -*- ruby -*-

require 'rubygems'
require 'hoe'

$LOAD_PATH << './lib'
require 'logback/version'

JARS = %w{ core classic access }.map do |n| 
  "logback-#{n}-#{ Logback::LOGBACK_VERSION }.jar"
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
lib/logback/version.rb
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

hoe = Hoe.new( "logback", Logback::VERSION ) do |p|
  p.developer( "David Kellum", "dek-gem@gravitext.com" )
# p.need_tar = false
end
hoe.spec.dependencies.delete_if { |dep| dep.name == "hoe" }

