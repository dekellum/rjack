# -*- ruby -*-

require 'rubygems'
require 'hoe'

$LOAD_PATH << './lib'
require 'logback/version'

assembly = 'target/logback-assembly-1.0-bin.dir/logback-assembly-1.0'

file assembly do
  sh( 'mvn package' )
end

task :jars => [ assembly ] do
  cp_r( assembly, 'lib/logback' )
end

hoe = Hoe.new( "logback", Logback::VERSION ) do |p|
  p.developer( "David Kellum", "dek-gem@gravitext.com" )
  p.need_tar = true
end
 
hoe.spec.dependencies.delete_if { |dep| dep.name == "hoe" }

