# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-jets3t/base'

  s.version = RJack::JetS3t::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-slf4j',         '>= 1.5.8',  '< 1.7'
  s.depend 'rjack-httpclient-4',  '>= 4.1.2',  '< 4.3'
  s.depend 'rjack-commons-codec', '>= 1.4.2',  '< 1.7'

  s.depend 'rjack-logback',       '>= 0.9.18', '< 2.0',  :dev
  s.depend 'minitest',            '~> 2.2',              :dev

  s.assembly_version = '1.0'
  s.maven_strategy = :jars_from_assembly
end
