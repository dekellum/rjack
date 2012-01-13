$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'rubygems'
require 'bundler/setup'

require 'minitest/unit'
require 'minitest/autorun'
