# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-protobuf/base'

  s.version = RJack::ProtoBuf::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'minitest',              '~> 4.7.4',     :dev

  s.assembly_version = '1.0'

  s.jars = [ "protobuf-java-#{ RJack::ProtoBuf::PB_VERSION }.jar" ]
end
