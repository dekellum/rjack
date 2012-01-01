# -*- ruby -*- encoding: utf-8 -*-

gem 'rjack-tarpit', '~> 2.0.a.0'
require 'rjack-tarpit/spec'

# Avoid adding lib to $LOAD_PATH since we want to use an installed
# rjack-maven (via tarpit) to build self.
load File.join( File.dirname( __FILE__ ), 'lib', 'rjack-maven', 'base.rb' )

RJack::TarPit.specify do |s|

  s.version  = RJack::Maven::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.maven_strategy = :jars_from_assembly
  s.assembly_version = 1.0

  s.depend 'minitest',        '~> 2.3',       :dev
  s.depend 'rjack-tarpit',    '~> 2.0',       :dev

  # Since an install'd rjack-maven will be used to build this, avoid warnings
  # by removing constants already used above.
  RJack::Maven.module_eval do
    %w[ VERSION MAVEN_VERSION LIB_DIR ].each do |c|
      remove_const( c )
    end
  end

end
