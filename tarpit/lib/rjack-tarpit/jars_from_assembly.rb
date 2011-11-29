#--
# Copyright (c) 2009-2011 David Kellum
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You
# may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#++

require 'rjack-tarpit/base'
require 'rjack-tarpit/spec'
require 'rjack-tarpit/gem'
require 'rjack-tarpit/clean'

module RJack::TarPit

  # Strategy in which the jars are inferred only by inspecting the
  # the completed maven assembly. The :manifest task is thus
  # dependent on 'mvn package'. Manifest changes need to be manually
  # incorporated by explicitly running "jrake manifest"
  class JarsFromAssembly < BaseStrategy

    # Define all tasks based on provided details.
    def define_tasks
      define_maven_package_task

      mtask = define_manifest_task

      task :manifest => [ MVN_STATE_FILE ]

      define_post_maven_tasks

      define_git_tag
      define_gem_tasks
      @defines.each { |sym| send( sym ) }
    end

    # For manifest, map destination jars from available jars in
    # (jar_from) target/assembly. These are available since mvn
    # package will be run first for the :manifest target.
    def dest_jars
      jars = FileList[ File.join( jar_from, "*.jar" ) ]
      jars = jars.map { |j| File.basename( j ) }.sort
      jars.map { |j| File.join( jar_dest, j ) }
    end

    # Extract jar files from saved Manifest state, since
    # neither from or dest jars may be available at call time.
    def jars
      unless @jars
        files = read_file_list( 'Manifest.txt' ).select { |f| f =~ /\.jar$/ }
        @jars = files.map { |f| File.basename( f ) }
      end
      @jars
    end

  end

end
