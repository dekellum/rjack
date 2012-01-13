# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-jms/base'

  s.version = RJack::JMS::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-slf4j',         '>= 1.5.8',  '< 1.7'
  s.depend 'rjack-jms-spec',      '~> 1.1.1'

  s.depend 'rjack-logback',       '>= 0.9.18', '< 2.0',  :dev
  s.depend 'minitest',            '~> 2.2',              :dev

  s.maven_strategy = :no_assembly
end
