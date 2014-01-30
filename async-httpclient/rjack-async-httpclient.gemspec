# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-async-httpclient/base'

  s.version = RJack::AsyncHTTPClient::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-netty',           '~> 3.6.6'
  s.depend 'rjack-slf4j',           '>= 1.6.5', '< 1.8'

  s.depend 'rjack-logback',         '~> 1.2',       :dev
  s.depend 'minitest',              '~> 4.7.4',     :dev
  s.depend 'rdoc',                  '~> 4.0.1',     :dev

  s.maven_strategy   = :jars_from_assembly
  s.assembly_version = '1.0'
end
