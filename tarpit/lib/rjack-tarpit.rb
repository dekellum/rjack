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
      @hoe_specifier = :unset
    end

    # Specify gem project details, yielding hoe instance to block after
    # setting various defaults.
    def specify( &block )
      @hoe_specifier = block
    end

    def define_tasks
      if @jars || @generated_files
        mtask = define_manifest_task #FIXME: Block?

        # The manifiest needs to run before hoe_sepcify.
        mtask.invoke
      end

      hoe_specify

      if @jars
        define_maven_tasks
      end

      define_git_tag
    end

    # Define task for dynamicly generating Manifest.txt, by
    # appending array returned by the given block to specifed files, or
    # contents of Manifest.static.
    def define_manifest_task( &dynamic_files )

      if File.exist?( 'Manifest.static' )
        file 'Manifest.txt' => [ 'Manifest.static' ]
      end

      gf = @generated_files.to_a.compact.sort
      [ :gem, :test ].each { |t| task t => gf }

      unless gf.empty?
        task :gen_clean do
          rm_f gf
        end
        task :clean => :gen_clean
      end

      ftask = file 'Manifest.txt' do
        m = []
        if File.exist?( 'Manifest.static' )
          m += read_static_files( 'Manifest.static' )
        end
        m += gf
        m += jar_dest_files
        if dynamic_files
          m += dynamic_files.call.to_a.reject { |f| f.empty? }.compact.sort
        end

        puts "TARPIT: Rewriting Manifest.txt"
        open( 'Manifest.txt', 'w' ) { |out| out.puts m }
      end

      ftask
    end

    # A file used to record the time of last 'mvn package' run.
    MVN_STATE_FILE = 'target/.tarpit'

    def define_maven_tasks
      file MVN_STATE_FILE => maven_dependencies do
        sh( 'mvn package' ) && touch( MVN_STATE_FILE )
      end
      ap = assembly_path
      @jars.each do |jar|
        from = File.join( ap, jar )
        dest = File.join( @jar_dest, jar )
        file from => [ MVN_STATE_FILE ]
        file_create dest => [ from ] do
          ln_s( File.join( '..', '..', from ), dest )
        end
        [ :gem, :test ].each { |t| task t => dest }
      end

      task :mvn_clean do
        rm_f jar_dest_files
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

    def maven_dependencies
      deps  = [ 'pom.xml' ]
      deps << 'assembly.xml' if File.exist?( 'assembly.xml' )
      deps += FileList[ "src/**/*" ].exclude { |f| ! File.file?( f ) }
      deps
    end

    def jar_dest_files
      @jars.to_a.sort.map { |j| File.join( @jar_dest, j ) }
    end

    def assembly_path
      File.join( 'target',
                 [ assembly_name || name,
                   assembly_version || @version,
                   'bin.dir' ].join('-') )
    end

    def read_static_files( sfile )
      fs = open( sfile ) { |f| f.readlines }
      fs.map { |f| f.strip }.reject { |f| f.empty? }.compact
    end

  end

end
