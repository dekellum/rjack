#--
# Copyright (c) 2011-2013 David Kellum
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#++

require 'rjack-zookeeper/base'

require 'rjack-slf4j'

require 'java'

module RJack::RZooKeeper

  Dir.glob( File.join( LIB_DIR, '*.jar' ) ).each { |jar| require jar }

  java_import "org.apache.zookeeper.ZooKeeper"
  java_import "org.apache.zookeeper.ZooKeeperMain"
  java_import "org.apache.zookeeper.server.quorum.QuorumPeerMain"

end
