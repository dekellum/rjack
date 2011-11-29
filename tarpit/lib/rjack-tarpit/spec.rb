require 'rjack-tarpit/base'

module RJack::TarPit

  class << self
    attr_reader :last_spec

    def specify( &block )
      @last_spec = Spec.new( &block )
    end
  end

  class Spec < Gem::Specification

    # FIXME: Hoe
    # Optional: The filename for the project readme. [default: README.txt]
    attr_accessor :readme_file

    # FIXME: Hoe
    # Optional: The filename for the project history. [default: History.txt]
    attr_accessor :history_file

    # FIXME: Hoe
    # Optional: An array of rubygem dependencies.
    #
    #   extra_deps << ['blah', '~> 1.0']
    attr_accessor :extra_deps

    # FIXME: Hoe
    # Optional: An array of rubygem developer dependencies.
    attr_accessor :extra_dev_deps

    def initialize

      # call with empty block
      super() {}

      # Better defaults
      if File.exist?( 'Manifest.txt' )
        self.files = File.open( 'Manifest.txt' ) { |fin| fin.readlines }.map { |f| f.strip }
      end

      @readme_file  = existing( %w[ README.rdoc README.txt ] )
      @history_file = existing( %w[ History.rdoc History.txt ] )

      self.extra_rdoc_files += [ FileList[ '*.rdoc' ],
                                 @readme_file,
                                 @history_file ].flatten.compact.sort.uniq

      self.rdoc_options += [ '--main', @readme_file ] if @readme_file

      @extra_deps     = []
      @extra_dev_deps = []

      yield self if block_given?

      @extra_deps.each do |dep|
        add_dependency( *dep )
      end

      unless ( name == 'rjack-tarpit' ||
               extra_dev_deps.find { |n,*v| n == 'rjack-tarpit' } )
        extra_dev_deps << [ 'rjack-tarpit', "~> #{ RJack::TarPit::VERSION }" ]
      end

      @extra_dev_deps.each do |dep|
        add_development_dependency( *dep )
      end

    end

    def add_developer( author, email )
      ( self.authors ||= [] ) << author
      ( self.email   ||= [] ) << email
    end

    # FIXME: Hoe compatible
    alias :developer :add_developer

    def summary=( val )
      super( val.gsub( /\s+/, ' ' ).strip )
    end

    def description=( val )
      super( val.gsub( /\s+/, ' ' ).strip )
    end

    # Override Gem::Specification to support simple platform symbol/string, i.e. :java
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
