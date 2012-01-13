# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-commons-codec/base'

  s.version = RJack::CommonsCodec::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'minitest',              '~> 2.2',       :dev

  s.assembly_version = '1.0'

  s.jars = [ "commons-codec-#{ RJack::CommonsCodec::CODEC_VERSION }.jar" ]
end
