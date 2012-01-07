#--
# Copyright (c) 2009-2012 David Kellum
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

  module DocTaskDefiner

    # Destination directory for RDoc generated files. (default: doc)
    attr_accessor :rdoc_dir

    def initialize
      super

      @rdoc_dir = 'doc'

      add_define_hook( :define_doc_tasks )
    end

    def define_doc_tasks
      require 'rdoc/task'

      RDoc::Task.new( :rdoc ) do |t|
        t.rdoc_dir = rdoc_dir
        t.rdoc_files += spec.require_paths
        t.rdoc_files += spec.extra_rdoc_files
        t.options = spec.rdoc_options
      end

      task :docs => [ :rdoc ]
    end

  end

end
