# -*- ruby -*- encoding: utf-8 -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|

  # Avoid require since we need an install'd rjack-maven to build
  # self.
  load 'rjack-maven/base.rb'

  s.version = RJack::Maven::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.maven_strategy = :jars_from_assembly
  s.assembly_version = 1.0

  s.depend 'minitest',        '~> 4.7.4',     :dev
  s.depend 'rjack-tarpit',    '~> 2.0',       :dev
  s.depend 'rdoc',            '~> 4.0.1',     :dev

  # Since an install'd rjack-maven will be used to build this, avoid
  # warnings by removing constants loaded above.
  RJack::Maven.module_eval do
    %w[ VERSION MAVEN_VERSION LIB_DIR ].each do |c|
      remove_const( c )
    end
  end

end
