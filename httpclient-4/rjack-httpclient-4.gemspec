# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-httpclient-4/base'

  s.version = RJack::HTTPClient4::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-slf4j',           '>= 1.6.5', '< 1.8'
  s.depend 'rjack-commons-codec',   '>= 1.6.0', '< 1.10'

  s.depend 'rjack-logback',         '~> 1.2',   :dev
  s.depend 'minitest',              '~> 4.7.4', :dev
  s.depend 'rdoc',                  '~> 4.0.1', :dev

  s.maven_strategy   = :jars_from_assembly
  s.assembly_version = '1.0'
end
