# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-nekohtml/base'

  s.version = RJack::NekoHTML::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-xerces',          '~> 2.9.1'
  s.depend 'minitest',              '~> 4.7.4',     :dev

  s.assembly_version = '1.0'

  s.jars = [ "nekohtml-#{ RJack::NekoHTML::NEKOHTML_VERSION }.jar" ]
end
