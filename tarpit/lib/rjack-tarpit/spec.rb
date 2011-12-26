require 'rjack-tarpit/base'
require 'rjack-tarpit/readme_parser'

module RJack::TarPit

  class << self
    attr_reader :last_spec

    # Produce a Gem::Specification embellished with SpecHelper
    # conveniences and yield to block
    def specify( &block )

      # Embellish a Specification instance with SpecHelper.
      #
      # This way spec.to_yaml continues to be a Gem::Specification
      # object. Deriving our own Specification subclass would cause
      # problems with to_yaml.
      spec = Gem::Specification.new
      class << spec
        include SpecHelper
        include ReadmeParser
      end

      # Default name to the (name).gemspec that should be calling us
      spec.name = caller[0] =~ /([^\\\/]+)\.gemspec/ && $1

      spec.specify &block

      @last_spec = spec
    end
  end

  module SpecHelper

    # FIXME: Hoe
    # The filename for the project README
    # (default: README.rdoc or README.txt is present)
    attr_accessor :readme_file

    # FIXME: Hoe
    # The filename for the project History
    # (default: History.rdoc or History.txt is present)
    attr_accessor :history_file

    # FIXME: Hoe
    # Optional: An array of rubygem dependencies.
    attr_accessor :extra_deps

    # FIXME: Hoe
    # Optional: An array of rubygem developer dependencies.
    attr_accessor :extra_dev_deps

    # The set of jar file names (without path) to include. May be
    # lazily computed by other strategies.
    attr_writer :jars

    # Destination path for any jars [Default: lib/name]
    attr_accessor :jar_dest

    # Any additional generated files to be included [Default: nil]
    attr_accessor :generated_files

    # FIXME: :no_assembly or :jars_from_assembly [Default: nil]
    # :jars_from_assembly:: jars will be found in assembly rather then
    #                       set in Rakefile.
    # :no_assembly:: One jar created from source, jars=[default_jar],
    #                no assembly setup in maven.
    attr_accessor :maven_strategy

    def specify
      # Better defaults
      if File.exist?( 'Manifest.txt' )
        self.files = Util::read_file_list( 'Manifest.txt' )
      end

      @readme_file  = existing( %w[ README.rdoc README.txt ] )
      @history_file = existing( %w[ History.rdoc History.txt ] )

      self.extra_rdoc_files += [ Dir[ '*.rdoc' ],
                                 @readme_file,
                                 @history_file ].flatten.compact.sort.uniq

      self.rdoc_options += [ '--main', @readme_file ] if @readme_file

      @extra_deps      = []
      @extra_dev_deps  = []

      @jars            = nil
      @jar_dest        = nil
      @generated_files = nil
      @maven_strategy  = nil

      parse_readme( @readme_file ) if @readme_file

      yield self if block_given?

      @jar_dest ||= File.join( 'lib', name )

      @jars = Array( @jars ).compact
      @jars = nil if @jars.empty?

      if ( @jars.nil? &&
           ( ( @maven_strategy == :no_assembly ) ||
             ( @maven_strategy.nil? && File.exist?( 'pom.xml' ) ) ) )
        @jars = [ default_jar ]
      end

      # The platform is java if jars are specified.
      self.platform = :java if @jars

      # Add any of the Hoe style dependencies
      @extra_deps.each { |dep| add_dependency( *dep ) }
      @extra_dev_deps.each { |dep| add_development_dependency( *dep ) }

      # Add this tarpit version as dev dep unless already present
      unless ( name == 'rjack-tarpit' ||
               dependencies.find { |n,*v| n == 'rjack-tarpit' } )
        depend( 'rjack-tarpit', "~> #{ RJack::TarPit::VERSION }", :dev )
      end

    end

    def add_developer( author, email )
      ( self.authors ||= [] ) << author
      ( self.email   ||= [] ) << email
    end

    # FIXME: Hoe compatible
    alias :developer :add_developer

    # Add a dependencies by name, version requirements, and a final
    # optional :dev or :development symbol indicating its for
    # development.
    def depend( name, *args )
      if args.last == :dev || args.last == :development
        args.pop
        add_development_dependency( name, *args )
      else
        add_dependency( name, *args )
      end
    end

    def summary=( val )
      super( val.gsub( /\s+/, ' ' ).strip )
    end

    def description=( val )
      super( val.gsub( /\s+/, ' ' ).strip )
    end

    # Override Gem::Specification to support simple platform
    # symbol/string, i.e. :java
    def platform=( val )
      if val.is_a?( Symbol ) || val.is_a?( String )
        val = Gem::Platform.new( val.to_s )
      end
      super( val )
    end

    def jars
      if @jars.nil? && ( maven_strategy == :jars_from_assembly )

        # Extract jar files from saved Manifest state, since neither
        # from or dest jars may be available at call time.
        @jars =
          Util::read_file_list( 'Manifest.txt' ).
          select { |f| f =~ /\.jar$/ }.
          map    { |f| File.basename( f ) }
      end
      @jars ||= Array( @jars )
    end

    private

    def existing( files )
      files.find { |f| File.exist?( f ) }
    end

    # Return a default jar name built from name and version
    def default_jar
      "#{name}-#{version}.jar"
    end

  end
end
