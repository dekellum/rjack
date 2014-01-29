# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-lucene/base'

  s.version = RJack::Lucene::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-commons-codec', '>= 1.7.0', '< 1.9'
  s.depend 'minitest',            '~> 4.7.4',            :dev
  s.depend 'rjack-icu',           '>= 4.49.1', '< 4.52', :dev #optional
  s.depend 'rdoc',                '~> 4.0.1',            :dev

  s.assembly_version = '1.0'
  s.maven_strategy = :jars_from_assembly
end
