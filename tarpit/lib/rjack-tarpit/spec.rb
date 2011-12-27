#--
# Copyright (c) 2009-2011 David Kellum
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

require 'rjack-tarpit/base'
require 'rjack-tarpit/util'
require 'rjack-tarpit/readme_parser'

module RJack::TarPit

  class << self

    # The result of the last call to specify.
    attr_reader :last_spec

    # Produce a Gem::Specification embellished with SpecHelper,
    # ReadmeParser, and yield to block
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

      spec.tarpit_specify &block

      @last_spec = spec
    end
  end

  # Helper mixin for Gem::Specification, adding Manifest awareness,
  # maven strategy, jars and other generaated_files declarations, as
  # well as several convience methods and defaults. Many of these were
  # Hoe inspired or remain compatible with Hoe.spec
  module SpecHelper

    # The filename for the project README
    # (default: README.rdoc or README.txt is present)
    attr_accessor :readme_file

    # The filename for the project History
    # (default: History.rdoc or History.txt is present)
    attr_accessor :history_file

    # The set of jar file names (without path) to include. May be
    # auto-computed for :no_assembly (default_jar) or
    # :jars_from_assembly (from Manifest.txt) maven_strategy.
    attr_writer :jars

    # Destination path for any jar links
    # (default: lib/<name>)
    attr_accessor :jar_dest

    # Any additional generated files to be included.
    # (default: nil)
    attr_accessor :generated_files

    # Strategy for interacting with maven
    # (default: nil, none )
    # :jars_from_assembly:: jars will be found in assembly rather then
    #                       set in Rakefile.
    # :no_assembly:: One jar created from source, jars=[default_jar],
    #                no assembly setup in maven.
    attr_accessor :maven_strategy

    # The name of the assembly (default: name)
    attr_accessor :assembly_name

    # The version of the assembly, which might be static, i.e. "1.0",
    # if the pom is not shared (dependency jars only) (default:
    # version)
    attr_accessor :assembly_version

    # Set defaults, yields self to block, and finalizes
    def tarpit_specify

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

      @jars            = nil
      @jar_dest        = nil
      @generated_files = nil
      @maven_strategy  = nil

      parse_readme( @readme_file ) if @readme_file

      yield self if block_given?

      @assembly_name ||= name
      @assembly_version ||= version

      @jar_dest ||= File.join( 'lib', name )

      @jars = Array( @jars ).compact
      @jars = nil if @jars.empty?

      if ( @jars.nil? &&
           ( ( @maven_strategy == :no_assembly ) ||
             ( @maven_strategy.nil? && File.exist?( 'pom.xml' ) ) ) )
        @jars = [ default_jar ]
      end

      # The platform is java if jars are specified.
      self.platform = :java if !jars.empty?

      # Add this tarpit version as dev dep unless already present
      unless ( name == 'rjack-tarpit' ||
               dependencies.find { |n,*v| n == 'rjack-tarpit' } )
        depend( 'rjack-tarpit', "~> #{ RJack::TarPit::VERSION }", :dev )
      end

    end

    # Add developer with optional email.
    def add_developer( author, email = nil )
      ( self.authors ||= [] ) << author
      ( self.email   ||= [] ) << email if email
    end

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

    # Set summary. This override cleans up whitespace.
    def summary=( val )
      super( val.gsub( /\s+/, ' ' ).strip )
    end

    # Set summary. This override cleans up whitespace.
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

    # Return set or defaulted jar file names (without path)
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
