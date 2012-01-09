# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-async-httpclient/base'

  s.version  = RJack::AsyncHTTPClient::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-slf4j',           '~> 1.6.1'

  s.depend 'rjack-logback',         '~> 1.0',       :dev
  s.depend 'minitest',              '~> 2.3',       :dev

  s.maven_strategy   = :jars_from_assembly
  s.assembly_version = '1.0'
end