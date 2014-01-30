# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-mina/base'

  s.version = RJack::Mina::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-slf4j',         '>= 1.6.5',  '< 1.8'

  s.depend 'rjack-logback',       '~> 1.2',    :dev
  s.depend 'minitest',            '~> 4.7.4',  :dev
  s.depend 'rdoc',                '~> 4.0.1',  :dev

  s.assembly_version = '1.0'
  s.jars = [ "mina-core-#{ RJack::Mina::CORE_VERSION }.jar" ]
end
