# -*- ruby -*-

require 'rubygems'
require 'hoe'

$LOAD_PATH << './lib'
require 'slf4j'
require 'slf4j/jdk14' #Delegate class loader can't load this.

hoe = Hoe.new( "slf4j", SLF4J::VERSION ) do |p|
  p.developer( "David Kellum", "dek-gem@gravitext.com" )
  p.need_tar = true
end
 
hoe.spec.dependencies.delete_if { |dep| dep.name == "hoe" }

