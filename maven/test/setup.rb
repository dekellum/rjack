require 'rubygems'
require 'bundler/setup'

$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'minitest/unit'
require 'minitest/autorun'
