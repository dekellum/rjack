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
