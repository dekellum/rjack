$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'rubygems'
require 'bundler/setup'

require 'minitest/unit'
require 'minitest/autorun'

require 'rjack-slf4j/log4j-over-slf4j'
require 'rjack-logback'

RJack::Logback.config_console( :stderr => true )

if ARGV.include?( '-v' ) || ARGV.include?( '--verbose' )
  RJack::Logback.root.level = :debug
else
  RJack::Logback[ 'org.apache.zookeeper' ].level = :warn
end
