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

require 'rjack-tarpit/test'
require 'rjack-tarpit/gem'
require 'rjack-tarpit/clean'
require 'rjack-tarpit/line_match'
require 'rjack-tarpit/doc'

module RJack::TarPit

  # Base strategy implementation where jars are known by the
  # Rakefile (not :jars_from_assembly)
  class BaseStrategy

    #For rack ~> 0.9.0
    include Rake::DSL if defined?( Rake::DSL )

    include TestTaskDefiner
    include GemTaskDefiner
    include CleanTaskDefiner
    include LineMatchTaskDefiner
    include DocTaskDefiner

    include Util

    # The name of the assembly [Default: name]
    attr_writer :assembly_name

    # The version of the assembly, which might be static
    # (i.e. "1.0") if the pom is not shared (dependency jars only)
    # [Default: version]
    attr_writer :assembly_version

    attr_reader :spec

    # See TarPit.new
    def initialize( spec )
      @defines = []
      super()

      @spec = spec

      @install_request =
        Rake.application.top_level_tasks.include?( "install" )
    end

    def add_define_hook( sym )
      @defines << sym
    end

    # Define all tasks based on provided details. In this strategy,
    # the Manifest.txt task will be invoked prior to calling
    # Hoe.spec, thus any additional Manifest.txt dependencies
    # should be specified prior to this call.
    def define_tasks
      define_maven_package_task unless spec.jars.empty?

      if !spec.jars.empty? || spec.generated_files
        define_manifest_task
      end

      define_post_maven_tasks unless spec.jars.empty?

      define_git_tag
      define_gem_tasks
      @defines.each { |sym| send( sym ) }
    end

    # Define task for dynamically generating Manifest.txt, by
    # appending array returned by the given block to specified files, or
    # contents of Manifest.static.
    def define_manifest_task

      if File.exist?( 'Manifest.static' )
        file 'Manifest.txt' => [ 'Manifest.static' ]
      end

      gf = clean_list( spec.generated_files ).sort
      [ :gem, :test ].each { |t| task t => gf }

      unless gf.empty?
        task :gen_clean do
          rm_f gf
        end
        task :clean => :gen_clean
      end

      desc "Force update of Manifest.txt"
      task :manifest do
        generate_manifest
      end

      mtask = file 'Manifest.txt' do
        generate_manifest
      end

      mtask
    end

    # File touched to record the time of last successful 'mvn
    # package' run.
    MVN_STATE_FILE         = 'target/.tarpit'
    MVN_STATE_FILE_INSTALL = 'target/.tarpit-install'

    # Define a file task tracking calls to "mvn package"
    def define_maven_package_task
      [ MVN_STATE_FILE, MVN_STATE_FILE_INSTALL ].each do |sf|
        file sf => maven_dependencies do
          run_maven
        end
      end

      task :install => MVN_STATE_FILE_INSTALL
    end

    # Run Maven mvn package or install and touch state files.
    def run_maven
      mvn = [ 'mvn', @install_request ? 'install' : 'package' ].join( ' ' )
      sh( mvn ) do |ok,res|
        if ok
          touch( MVN_STATE_FILE )
          touch( MVN_STATE_FILE_INSTALL ) if @install_request
        else
          raise "TARPIT: '#{mvn}' failed."
        end
      end
    end

    # Define file tasks for all jar symlinks and other misc. maven
    # associated tasks like :mvn_clean.
    def define_post_maven_tasks
      jfrom = jar_from
      spec.jars.each do |jar|
        from = File.join( jfrom, jar )
        dest = File.join( spec.jar_dest, jar )
        file from => [ MVN_STATE_FILE ]
        file dest => [ from ] do
          ln( from, dest, :force => true )
        end
        [ :gem, :test ].each { |t| task t => [ dest ] }
      end

      task :mvn_clean do
        remove_dest_jars
        sh 'mvn clean'
      end
      task :clean => :mvn_clean
    end

    # Dependencies on "mvn package" including pom.xml, any assembly.xml,
    # all files under the "src" directory.
    def maven_dependencies
      deps  = [ 'pom.xml' ]
      deps << 'assembly.xml' if File.exist?( 'assembly.xml' )
      deps += FileList[ "src/**/*" ].exclude { |f| ! File.file?( f ) }
      deps
    end

    # Define git based :tag task
    def define_git_tag
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

    # Define gem push and install tasks
    def define_gem_tasks
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
      parts << 'java' if spec.platform == 'java'

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

    # Generate Manifest.txt
    def generate_manifest
      unless @generated_manifest #only once
        remove_dest_jars

        m = []
        if File.exist?( 'Manifest.static' )
          m += read_file_list( 'Manifest.static' )
        end
        m += clean_list( spec.generated_files ).sort
        m += dest_jars

        puts "TARPIT: Updating Manifest.txt"
        open( 'Manifest.txt', 'w' ) { |out| out.puts m }
        @generated_manifest = true
      end
    end

    # Remove jars in jar_dest by wildcard expression
    def remove_dest_jars
      jars = FileList[ File.join( spec.jar_dest, "*.jar" ) ].sort
      rm_f jars unless jars.empty?
    end

    # The list of jars in jar_dest path, used during manifest generation
    def dest_jars
      clean_list( spec.jars ).sort.map { |j| File.join( spec.jar_dest, j ) }
    end

    # The target/assembly path from which jars are linked
    def jar_from
      dirs = [ 'target' ]

      unless spec.maven_strategy == :no_assembly
        dirs << [ @assembly_name || spec.name,
                  @assembly_version || spec.version,
                  'bin.dir' ].join('-')
      end

      File.join( dirs )
    end

  end

end
