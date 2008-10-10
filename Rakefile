# -*- ruby -*-

require 'rubygems'
require 'hoe'

$LOAD_PATH << './lib'

require 'slf4j/version'

# Mapping from loader.rb -> jar
JAR_LOADERS = {}

# SLF4J output adapters
%w{ jcl jdk14 log4j12 nop simple }.each do |adp|
  JAR_LOADERS[ adp ] = 'slf4j-' + adp
end

# SLF4J input adapters
%w{ jcl-over-slf4j jul-to-slf4j log4j-over-slf4j }.each do |ra|
  JAR_LOADERS[ ra ] = ra
end

desc "Generate jar loader .rb's"
task :jar_loaders => [ :jars ] do
  JAR_LOADERS.each do |rb,jar| 
    out = File.new( "lib/slf4j/#{rb}.rb", 'w' )
    begin
      out.puts "SLF4J.require_jar '#{jar}'"
    ensure
      out.close
    end
  end
end

desc "Update the Manifest with actual jars/loaders"
task :manifest => [ :jars, :jar_loaders ] do
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
    Dir.glob( 'lib/slf4j/*.jar' ).each { |jar| out.puts( jar ) }
    JAR_LOADERS.keys.each { |rb| out.puts( "lib/slf4j/#{rb}.rb" ) }
  ensure
    out.close
  end
end

ASSEMBLY = "target/slf4j-assembly-1.0-bin.dir"

file ASSEMBLY => [ 'pom.xml', 'assembly.xml' ] do
  sh( 'mvn package' )
end

desc "Copy jars from maven assembly."
task :jars  => [ ASSEMBLY ] do
  cp_r( Dir.glob( ASSEMBLY + '/*.jar' ), 'lib/slf4j' )
end

[ :gem, :test ].each { |t| task t => [ :jars, :jar_loaders ] }

task :mvn_clean do
  rm_f( Dir.glob( 'lib/slf4j/*.jar' ) )
  JAR_LOADERS.keys.each { |rb| rm_f( "lib/slf4j/#{rb}.rb" ) }
  sh( 'mvn clean' )
end
task :clean => :mvn_clean 

hoe = Hoe.new( "slf4j", SLF4J::VERSION ) do |p|
  p.developer( "David Kellum", "dek-gem@gravitext.com" )
  p.need_tar = true
end
 
hoe.spec.dependencies.delete_if { |dep| dep.name == "hoe" }

