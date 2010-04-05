#--
# Copyright (C) 2009-2010 David Kellum
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

require 'hoe'

module RJack

  # Provides glue for Rake, Hoe, and Maven by generating tasks.
  module TarPit
    # Module version
    VERSION = '1.2.1'

    # Construct new task generator by gem name, version, and flags. A descendant
    # of BaseStrategy is returned.
    # ==== flags
    # :jars_from_assembly:: jars will be found in assembly rather then
    #                       set in Rakefile.
    # :no_assembly:: One jar created from source, jars=[default_jar],
    #                no assembly setup in maven.
    # :java_platform:: Set gem specification platform to java.
    def self.new( name, version, *flags )
      if flags.include?( :jars_from_assembly )
        JarsFromAssembly.new( name, version, flags )
      else
        BaseStrategy.new( name, version, flags )
      end
    end

    # Base strategy implementation where jars are known by the
    # Rakefile (not :jars_from_assembly)
    class BaseStrategy

      # Name of gem as constructed.
      attr_reader :name
      # Version of gem as constructed.
      attr_reader :version

      # The set of jar file names (without path) to include. May be
      # lazily computed by other strategies.
      attr_accessor :jars

      # Destination path for any jars [Default: lib/name]
      attr_accessor :jar_dest

      # Any additional generated files to be included [Default: nil]
      attr_accessor :generated_files

      # Use rdoc --diagram (requires http://graphiz.org 'dot' in PATH)
      attr_accessor :rdoc_diagram

      # The name of the assembly [Default: name]
      attr_writer :assembly_name

      # The version of the assembly, which might be static
      # (i.e. "1.0") if the pom is not shared (dependency jars only)
      # [Default: version]
      attr_writer :assembly_version

      # See TarPit.new
      def initialize( name, version, flags )
        @name = name
        @version = version
        @flags = flags
        @jars = [ default_jar ] if @flags.include?( :no_assembly )
        @jar_dest = File.join( 'lib', @name )
        @hoe_specifier = :unset
        @rdoc_diagram = false
        @spec = nil
      end

      # Return a default jar name built from name and version
      def default_jar
        "#{name}-#{version}.jar"
      end

      # Specify gem project details, yielding Hoe instance to block
      # after setting various defaults. Thus all Hoe.spec setters are
      # valid in this block. The actual Hoe construction and execution
      # of block is deferred to define_tasks.
      def specify( &block )
        @hoe_specifier = block
      end

      # Define all tasks based on provided details. In this strategy,
      # the Manifest.txt task will be invoked prior to calling
      # Hoe.spec, thus any additional Manifest.txt dependencies
      # should be specified prior to this call.
      def define_tasks
        define_maven_package_task if jars

        if jars || generated_files
          mtask = define_manifest_task

          # The manifest needs to run before hoe_specify
          mtask.invoke
        end

        define_post_maven_tasks if jars

        hoe_specify

        define_git_tag
        define_gem_tasks
      end

      # Test that all specified files have at least one line matching
      # line_regex, and that first line additionally matches (optional)
      # pass_line_regex.
      # ==== Parameters
      # files<~to_a>:: List of files to test
      # line_regex<Regexp>:: Test first matching line
      # pass_line_regex:: Further test on match line (default: match all)
      # ==== Raises
      # RuntimeError:: on test failure.
      def test_line_match( files, line_regex, pass_line_regex = // )
        files.to_a.each do |mfile|
          found = false
          open( mfile ) do |mf|
            num = 0
            mf.each do |line|
              num += 1
              if line =~ line_regex
                found = true
                unless line =~ pass_line_regex
                  raise( "%s:%d: %s !~ %s" %
                         [ mfile, num, line.strip, pass_line_regex.inspect ] )
                end
                break
              end
            end
          end
          unless found
            raise "#{mfile}: #{line_regex.inspect} not found"
          end
        end
      end

      # Define task for dynamically generating Manifest.txt, by
      # appending array returned by the given block to specified files, or
      # contents of Manifest.static.
      def define_manifest_task

        if File.exist?( 'Manifest.static' )
          file 'Manifest.txt' => [ 'Manifest.static' ]
        end

        gf = clean_list( generated_files ).sort
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
      MVN_STATE_FILE = 'target/.tarpit'

      # Define a file task tracking calls to "mvn package"
      def define_maven_package_task
        file MVN_STATE_FILE => maven_dependencies do
          sh( 'mvn package' ) do |ok,res|
            if ok
              touch( MVN_STATE_FILE )
            else
              raise "TARPIT: 'mvn package' failed."
            end
          end
        end
      end

      # Define file tasks for all jar symlinks and other misc. maven
      # associated tasks like :mvn_clean.
      def define_post_maven_tasks
        jfrom = jar_from
        jars.each do |jar|
          from = File.join( jfrom, jar )
          dest = File.join( jar_dest, jar )
          file from => [ MVN_STATE_FILE ]
          file dest => [ from ] do
            ln_sf( File.join( '..', '..', from ), dest )
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
          tag = [ name, version ].join( '-' )
          dname = Rake.original_dir
          dname = '.' if Dir.getwd == dname
          sh( "git status --only #{dname}" ) do |ok,res|
            if ok #changes present
              raise "Commit these changes before tagging."
            end
          end
          sh %{git tag -s -f -m "tag [#{tag}]" "#{tag}"}
        end
      end

      # Define gem push and install tasks
      def define_gem_tasks
        desc "gem push (gemcutter)"
        task :push => [ :gem ] do
          require 'rubygems'
          cm = Gem::CommandManager.instance
          cm.run( gem_config( 'push' ) +
                  [ '-V', gem_file ] )
        end

        desc "gem install (default install dir)"
        task :install => [ :gem ] do
          require 'rubygems'
          cm = Gem::CommandManager.instance
          cm.run( gem_config( 'install' ) +
                  [ '--no-ri', '-V', gem_file ] )
        end
      end

      def gem_file
        parts = [ name, version ]
        if @spec
          pform = @spec.spec_extras[ :platform ]
          parts << 'java' if ( pform && pform.os == 'java' )
        end

        "pkg/#{ parts.join( '-' ) }.gem"
      end

      def gem_config( command )
        cargs = Gem.configuration[ command ]
        cargs = cargs.is_a?( String ) ? cargs.split( ' ' ) : cargs.to_a
        [ command ] + cargs
      end

      # Setup Hoe via Hoe.spec
      def hoe_specify

        unless @rdoc_diagram
          # Silly Hoe sets up DOT with rdoc unless this is set.
          ENV['NODOT'] = "no thanks"
        end

        unless @hoe_specifier == :unset
          tp = self
          outer = @hoe_specifier
          jplat = @flags.include?( :java_platform )
          @spec = Hoe.spec( @name ) do |h|

            h.version = tp.version
            h.readme_file  =  'README.rdoc' if File.exist?(  'README.rdoc' )
            h.history_file = 'History.rdoc' if File.exist?( 'History.rdoc' )
            h.extra_rdoc_files = FileList[ '*.rdoc' ]

            h.spec_extras[ :platform ] = Gem::Platform.new( "java" ) if jplat

            outer.call( h )
          end
        end
      end

      # Generate Manifest.txt
      def generate_manifest
        remove_dest_jars

        m = []
        if File.exist?( 'Manifest.static' )
          m += read_file_list( 'Manifest.static' )
        end
        m += clean_list( generated_files ).sort
        m += dest_jars

        puts "TARPIT: Updating Manifest.txt"
        open( 'Manifest.txt', 'w' ) { |out| out.puts m }
      end

      # Remove jars in jar_dest by wildcard expression
      def remove_dest_jars
        jars = FileList[ File.join( jar_dest, "*.jar" ) ].sort
        rm_f jars unless jars.empty?
      end

      # The list of jars in jar_dest path, used during manifest generation
      def dest_jars
        clean_list( jars ).sort.map { |j| File.join( jar_dest, j ) }
      end

      # The target/assembly path from which jars are linked
      def jar_from
        dirs = [ 'target' ]

        unless @flags.include?( :no_assembly )
          dirs << [ @assembly_name || name,
                    @assembly_version || version,
                    'bin.dir' ].join('-')
        end

        File.join( dirs )
      end

      # Read a list of files and return a cleaned list.
      def read_file_list( sfile )
        clean_list( open( sfile ) { |f| f.readlines } )
      end

      # Cleanup a list of files
      def clean_list( l )
        l = l.to_a.compact
        l.map! { |f| f.strip }
        l.map! { |f| f.empty? ? nil : f }
        l.compact!
        l
      end

    end

    # Strategy in which the jars are inferred only by inspecting the
    # the completed maven assembly. The :manifest task is thus
    # dependent on 'mvn package'. Manifest changes need to be manually
    # incorporated by explicitly running "jrake manifest"
    class JarsFromAssembly < BaseStrategy

      # Define all tasks based on provided details. Don't invoke
      # Manifest.txt before Hoe, just use whats already in place.
      def define_tasks
        define_maven_package_task

        mtask = define_manifest_task

        task :manifest => [ MVN_STATE_FILE ]

        define_post_maven_tasks

        hoe_specify

        define_git_tag
        define_gem_tasks
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

end

# Replace special Hoe development dependency with rjack-tarpit (which
# itself depends on constrained version of Hoe.)
class Hoe
  def add_dependencies
    self.extra_deps     = normalize_deps extra_deps
    self.extra_dev_deps = normalize_deps extra_dev_deps

    unless name == 'rjack-tarpit'
      extra_dev_deps << [ 'rjack-tarpit', "~> #{ RJack::TarPit::VERSION }" ]
    end
  end
end
