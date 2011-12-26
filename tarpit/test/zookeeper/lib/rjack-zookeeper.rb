require 'rjack-zookeeper/base'

require 'rjack-slf4j'

require 'java'

module RJack::RZooKeeper

  Dir.glob( File.join( LIB_DIR, '*.jar' ) ).each { |jar| require jar }

  java_import "org.apache.zookeeper.ZooKeeper"

end
