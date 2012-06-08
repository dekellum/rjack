# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-lucene/base'

  s.version = RJack::Lucene::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-commons-codec', '~> 1.6.0'
  s.depend 'minitest',            '~> 2.2',              :dev
  s.depend 'rjack-icu',           '~> 4.8.1.1',          :dev #optional

  s.assembly_version = '1.0'
  s.maven_strategy = :jars_from_assembly
end
