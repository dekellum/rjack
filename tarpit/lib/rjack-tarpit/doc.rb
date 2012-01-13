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

    # Local destination directory for RDoc generated files.
    # (default: doc)
    attr_accessor :rdoc_dir

    # Remote destinations array for publish_rdoc. (default: [])
    attr_accessor :rdoc_destinations

    # Rsync flags for publish_rdoc. (default: %w[ -a -u -i ])
    attr_accessor :publish_rdoc_rsync_flags

    def initialize
      super

      @rdoc_dir = 'doc'
      @rdoc_destinations = []
      @publish_rdoc_rsync_flags = %w[ -a -u -i ]

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

      unless rdoc_destinations.empty?
        desc "Publish rdoc to #{ rdoc_destinations.join( ', ' ) }"
        task :publish_rdoc => [ :docs ] do
          rdoc_destinations.each do |dest|
            sh( *[ 'rsync', publish_rdoc_rsync_flags,
                   rdoc_dir + '/', dest ].flatten )
          end
        end
      end

      desc "Alias rdoc task"
      task :docs => [ :rdoc ]
    end

  end

end
