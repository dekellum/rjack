# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-httpclient-3/base'

  s.version = RJack::HTTPClient3::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-slf4j',           '>= 1.5.8',  '< 1.7'
  s.depend 'rjack-commons-codec',   '~> 1.4'

  s.depend 'rjack-logback',         '>= 0.9.18', '< 2.0',     :dev
  s.depend 'minitest',              '~> 2.2',                 :dev

  s.assembly_version = '1.0'
  s.jars =
    [ "commons-httpclient-#{ RJack::HTTPClient3::HTTPCLIENT_VERSION }.jar" ]
end
