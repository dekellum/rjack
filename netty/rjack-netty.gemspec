# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-netty/base'

  s.version = RJack::Netty::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-slf4j',         '>= 1.6.5',  '< 1.8'

  s.depend 'rjack-logback',       '~> 1.2',    :dev
  s.depend 'minitest',            '~> 2.2',    :dev

  s.assembly_version = '1.0'
  s.jars = [ "netty-#{ RJack::Netty::NETTY_VERSION }.jar" ]
end
