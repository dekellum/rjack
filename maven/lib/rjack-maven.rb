#--
# Copyright (c) 2012-2017 David Kellum
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

require 'rjack-maven/base'

require 'java'

module RJack::Maven

  BASE_DIR = File.expand_path( '..', File.dirname(__FILE__) )

  Dir.glob( File.join( LIB_DIR, '*.jar' ) ).each { |jar| require jar }

  import 'org.codehaus.plexus.classworlds.launcher.Launcher'

  def self.setup_system_properties
    sys = Java::java.lang.System

    sys.set_property( "maven.home", BASE_DIR )
    sys.set_property( "classworlds.conf",
                      File.join( BASE_DIR, 'config', 'm2.conf' ) )
  end

  setup_system_properties

  # Launch maven with args, using plexis launcher.
  # Returns exit status.
  def self.launch( args = ARGV )
    Launcher.main_with_exit_code( args )
  end

end
