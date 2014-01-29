# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-jackson/base'

  s.version = RJack::Jackson::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'minitest',              '~> 4.7.4',     :dev
  s.depend 'rdoc',                  '~> 4.0.1',     :dev

  s.assembly_version = '1.0'

  s.jars = %w[ core databind annotations ].
    map { |m| "jackson-#{m}-#{ RJack::Jackson::JACKSON_VERSION }.jar" }
end
