# -*- ruby -*- encoding: utf-8 -*-

gem 'rjack-tarpit', '~> 2.0.a.0'
require 'rjack-tarpit/spec'

$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), 'lib' ) )

require 'rjack-maven/base'

RJack::TarPit.specify do |s|

  s.version  = RJack::Maven::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.maven_strategy = :jars_from_assembly
  s.assembly_version = 1.0

  s.depend 'minitest',        '~> 2.3',       :dev
end
