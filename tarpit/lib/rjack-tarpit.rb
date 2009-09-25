require 'hoe'

# Silly Hoe sets up DOT with rdoc unless this is set.
ENV['NODOT'] = "no thanks"

module RJack
  class TarPit
    VERSION = '1.0.0'

    attr_reader :name

    attr_accessor( :version, :jars, :jar_dest,
                   :assembly_name, :assembly_version,
                   :generated_files )

    def initialize( name )
      @name = name
      @jars = nil
      @jar_dest = File.join( 'lib', @name )
      @find_jars_in_assembly = false
      @hoe_specifier = :unset
    end

    # Specify gem project details, yielding hoe instance to block after
    # setting various defaults.
    def specify( &block )
      @hoe_specifier = block
    end

    def find_jars_in_assembly
      @find_jars_in_assembly = true
    end

    def define_tasks
      if @jars || @find_jars_in_assembly
        define_maven_package_task
      end

      if @jars || @find_jars_in_assembly || @generated_files
        mtask = define_manifest_task #FIXME: Block?

        if @find_jars_in_assembly
          task :manifest => [ MVN_STATE_FILE ]
        end

        # The manifiest needs to run before hoe_specify
        mtask.invoke
      end

      if @jars || @find_jars_in_assembly
        define_post_maven_tasks
      end

      hoe_specify

      define_git_tag
    end

    # Define task for dynamicly generating Manifest.txt, by
    # appending array returned by the given block to specifed files, or
    # contents of Manifest.static.
    def define_manifest_task

      if File.exist?( 'Manifest.static' )
        file 'Manifest.txt' => [ 'Manifest.static' ]
      end

      gf = clean_list( @generated_files ).sort
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

    # A file used to record the time of last 'mvn package' run.
    MVN_STATE_FILE = 'target/.tarpit'

    def define_maven_package_task
      file MVN_STATE_FILE => maven_dependencies do
        sh( 'mvn package' ) && touch( MVN_STATE_FILE )
      end
    end

    def define_post_maven_tasks
      ap = assembly_path
      jars_lazy.each do |jar|
        from = File.join( ap, jar )
        dest = File.join( @jar_dest, jar )
        file from => [ MVN_STATE_FILE ]
        file_create dest => [ from ] do
          ln_s( File.join( '..', '..', from ), dest )
        end
        puts "TARPIT: :test => #{dest.inspect}"
        [ :gem, :test ].each { |t| task t => [ dest ] }
      end

      task :mvn_clean do
        rm_f jar_dest_files #FIXME: Use pattern, since this can result in assembly being called?
        sh 'mvn clean'
      end
      task :clean => :mvn_clean
    end

    def define_git_tag
      task :tag do
        tag = [ @name, @version ].join( '-' )
        dname = File.dirname( __FILE__ )
        dname = '.' if Dir.getwd == dname
        sh( "git status --only #{dname}" ) do |ok,res|
          if ok #changes present
            raise "Commit these changes before tagging."
          end
        end
        sh %{git tag -s -f -m "tag [#{tag}]" "#{tag}"}
      end
    end

    def hoe_specify
      unless @hoe_specifier == :unset
        tp = self
        outer = @hoe_specifier
        Hoe.spec( @name ) do |h|
          h.version = tp.version

          h.readme_file  =  'README.rdoc' if File.exist?(  'README.rdoc' )
          h.history_file = 'History.rdoc' if File.exist?( 'History.rdoc' )
          h.extra_rdoc_files = FileList[ '*.rdoc' ]

          outer.call( h )
        end
      end
    end

    def generate_manifest
      m = []
      if File.exist?( 'Manifest.static' )
        m += read_static_files( 'Manifest.static' )
      end
      m += clean_list( @generated_files ).sort
      m += jar_dest_files

      puts "TARPIT: Updating Manifest.txt"
      open( 'Manifest.txt', 'w' ) { |out| out.puts m }
    end

    def maven_dependencies
      deps  = [ 'pom.xml' ]
      deps << 'assembly.xml' if File.exist?( 'assembly.xml' )
      deps += FileList[ "src/**/*" ].exclude { |f| ! File.file?( f ) }
      deps
    end

    def jars_lazy
      if @find_jars_in_assembly
        @jars = FileList[ "#{assembly_path}/*.jar" ]
        @jars.map! { |f| File.basename( f ) }
        puts "TARPIT jars_lazy : #{@jars.inspect}"
        #FIXME: Safe to do once? @find_jars_from_assembly = false
      end
      @jars
    end

    def jar_dest_files
      clean_list( jars_lazy ).sort.map { |j| File.join( @jar_dest, j ) }
    end

    def assembly_path
      File.join( 'target',
                 [ assembly_name || name,
                   assembly_version || @version,
                   'bin.dir' ].join('-') )
    end

    def read_static_files( sfile )
      clean_list( open( sfile ) { |f| f.readlines } )
    end

    def clean_list( l )
      l = l.to_a.compact
      l.map! { |f| f.strip }
      l.map! { |f| f.empty? ? nil : f }
      l.compact!
      l
    end

  end

end
