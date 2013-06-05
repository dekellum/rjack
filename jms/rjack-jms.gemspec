# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-jms/base'

  s.version = RJack::JMS::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-slf4j',         '>= 1.6.5',  '< 1.8'
  s.depend 'rjack-jms-spec',      '~> 1.1.1'

  s.depend 'rjack-logback',       '~> 1.2',    :dev
  s.depend 'minitest',            '~> 4.7.4',  :dev

  s.maven_strategy = :no_assembly
end
