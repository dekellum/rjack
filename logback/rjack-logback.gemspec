# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-logback/base'

  s.version = RJack::Logback::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-slf4j',           '~> 1.7.16'

  s.depend 'minitest',              '~> 4.7.4', :dev
  s.depend 'rdoc',           '>= 4.0.1', '< 5', :dev

  s.assembly_version = '1.0'

  s.jars = %w[ core classic access ].
    map { |j| "logback-#{j}-#{ RJack::Logback::LOGBACK_VERSION }.jar" }
end
