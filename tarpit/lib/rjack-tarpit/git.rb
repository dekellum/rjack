#--
# Copyright (c) 2009-2013 David Kellum
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

module RJack::TarPit

  module GitTaskDefiner

    def initialize
      super

      add_define_hook( :define_git_tasks )
    end

    # Define git based :tag task
    def define_git_tasks
      desc "git tag current version"
      task :tag do
        tag = [ spec.name, spec.version ].join( '-' )
        dname = Rake.original_dir
        dname = '.' if Dir.getwd == dname
        delta = `git status --porcelain -- #{dname} 2>&1`.split(/^/)
        if delta.length > 0
          puts delta
          raise "Commit these changes before tagging"
        end
        sh %{git tag -s -f -m "tag [#{tag}]" "#{tag}"}
      end
    end

  end

end
