#--
# Copyright (c) 2009-2012 David Kellum
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
require 'rjack-tarpit/util'
require 'rjack-tarpit/spec'

require 'rjack-tarpit/test'
require 'rjack-tarpit/gem'
require 'rjack-tarpit/clean'
require 'rjack-tarpit/line_match'
require 'rjack-tarpit/doc'
require 'rjack-tarpit/git'

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
    include GitTaskDefiner

    include Util

    # The augmented Gem::Specification as constructed.
    attr_reader :spec

    # See TarPit.new
    def initialize( spec )
      @defines = [ :define_maven_tasks ]
      super()

      @spec = spec

      @install_request = Rake.application.top_level_tasks.include?( "install" )
    end

    def add_define_hook( sym )
      @defines << sym
    end

    def define_tasks
      @defines.each { |sym| send( sym ) }
    end

    # Define maven tasks based on spec strategy and other details.
    def define_maven_tasks
      from_assembly = ( spec.maven_strategy == :jars_from_assembly )
      do_maven = from_assembly || spec.jars.size > 0

      define_maven_package_task if do_maven

      if do_maven || spec.generated_files
        define_manifest_task
        task( :manifest => [ MVN_STATE_FILE ] ) if from_assembly
      end

      define_post_maven_tasks if do_maven
    end

    # Define task for dynamically generating Manifest.txt
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
        spec.generate_manifest
      end

      mtask = file 'Manifest.txt' do
        spec.generate_manifest
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
      # Delay till now, in case we were not running on jvm
      require 'rjack-maven'

      target = @install_request ? 'install' : 'package'

      status = RJack::Maven.launch( [ target ] )
      unless status == 0
        raise "TARPIT: Maven #{target} failed (exit code: #{status})"
      end

      touch( MVN_STATE_FILE )
      touch( MVN_STATE_FILE_INSTALL ) if @install_request
    end

    # Define file tasks for all jar symlinks and other misc. maven
    # associated tasks like :mvn_clean.
    def define_post_maven_tasks
      jfrom = spec.jar_from
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
        spec.remove_dest_jars
        rm_rf 'target' if File.directory?( 'target' )
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

  end

end
