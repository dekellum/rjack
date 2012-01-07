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

      add_define_hook( :define_gem_tasks )
    end

    def define_gem_tasks

      Gem::PackageTask.new( spec ) do |pkg|
        pkg.need_tar = @need_tar
        pkg.need_zip = @need_zip
      end

      desc 'Dump plain ruby Gem::Specification'
      task :debug_gem do
        puts spec.to_ruby
      end

      desc "gem push (gemcutter)"
      task :push => [ :gem ] do
        require 'rubygems'
        require 'rubygems/command_manager'
        cm = Gem::CommandManager.instance
        cm.run( gem_config( 'push', '-V', gem_file ) )
      end

      desc "gem(+maven) install"
      task :install => [ :gem ] do
        require 'rubygems'
        require 'rubygems/command_manager'
        cm = Gem::CommandManager.instance
        begin
          cm.run( gem_config( 'install', '--local', '-V', gem_file ) )
        rescue Gem::SystemExitException => x
          raise "Install failed (#{x.exit_code})" if x.exit_code != 0
        end
      end

      desc "gem install missing/all dev dependencies"
      task( :install_deps, :force ) do |t,args|
        require 'rubygems'
        require 'rubygems/command_manager'
        force = ( args[:force] == 'force' )
        ( @spec.extra_deps + @spec.extra_dev_deps ).each do |dep|
          if force
            gem_install_dep( dep )
          else
            begin
              gem( *dep )
            rescue Gem::LoadError => e
              puts "Gem dep: " + e.to_s
              gem_install_dep( dep )
            end
          end
        end
      end
    end

    def gem_install_dep( dep )
      puts "Install: " + dep.inspect
      cm = Gem::CommandManager.instance
      c = [ 'install', '--remote', '-V', dep.first ]
      c += dep[1..-1].map { |r| [ '-v', r ] }.flatten
      cm.run( gem_config( *c ) )
    rescue Gem::SystemExitException => x
      raise "Install failed (#{x.exit_code})" if x.exit_code != 0
    end

    def gem_file
      parts = [ spec.name, spec.version ]
      p = spec.platform
      parts << 'java' if p.respond_to?( :os ) && p.os == 'java'

      "pkg/#{ parts.join( '-' ) }.gem"
    end

    def gem_config( command, *args )
      cargs = [ 'gem', command ].map do |cmd|
        conf = Gem.configuration[ cmd ]
        conf.is_a?( String ) ? conf.split( ' ' ) : Array( conf )
      end
      cargs.flatten!
      [ command ] + cargs + args
    end

  end

end
