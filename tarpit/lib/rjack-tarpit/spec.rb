require 'rjack-tarpit/base'

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
      end
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

    def specify
      # Better defaults
      if File.exist?( 'Manifest.txt' )
        self.files =
          File.open( 'Manifest.txt' ) { |fin| fin.readlines }.
          map { |f| f.strip }
      end

      @readme_file  = existing( %w[ README.rdoc README.txt ] )
      @history_file = existing( %w[ History.rdoc History.txt ] )

      self.extra_rdoc_files += [ Dir[ '*.rdoc' ],
                                 @readme_file,
                                 @history_file ].flatten.compact.sort.uniq

      self.rdoc_options += [ '--main', @readme_file ] if @readme_file

      @extra_deps     = []
      @extra_dev_deps = []

      yield self if block_given?

      # Add any of the Hoe style dependencies
      @extra_deps.each do |dep|
        add_dependency( *dep )
      end

      @extra_dev_deps.each do |dep|
        add_development_dependency( *dep )
      end

      unless ( name == 'rjack-tarpit' ||
               dependencies.find { |n,*v| n == 'rjack-tarpit' } )
        extra_dev_deps << [ 'rjack-tarpit', "~> #{ RJack::TarPit::VERSION }" ]
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

    private

    def existing( files )
      files.find { |f| File.exist?( f ) }
    end

  end
end
