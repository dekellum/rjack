require 'rubygems/package_task'

module RJack::TarPit

  module GemTaskDefiner

    # Should package create a tarball? (default: false)
    attr_accessor :need_tar

    # Should package create a zipfile? (default: false)
    attr_accessor :need_zip

    def initialize
      super

      @need_tar = false
      @need_zip = false

      add_define_hook( :define_new_gem_tasks )
    end

    def define_new_gem_tasks

      Gem::PackageTask.new( spec ) do |pkg|
        pkg.need_tar = @need_tar
        pkg.need_zip = @need_zip
      end

      desc 'Dump plain ruby Gem::Specification'
      task :debug_gem do
        puts spec.to_ruby
      end

    end

  end

end
