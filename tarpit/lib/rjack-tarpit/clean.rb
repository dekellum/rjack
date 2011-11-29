module RJack::TarPit

  module CleanTaskDefiner

    # An array of file patterns to delete on clean.
    attr_accessor :clean_globs

    def initialize
      super

      @clean_globs ||= %w[ .source_index **/*~ **/.*~ ]

      add_define_hook( :define_clean_tasks )
    end

    def define_clean_tasks
      desc 'Clean up (common backup file patterns)'
      task :clean do
        files = clean_globs.map { |p| Dir[ p ] }
        rm_rf( files, :verbose => true ) unless files.empty?
      end
    end

  end

end
