# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-logback/base'
  include RJack

  s.version  = Logback::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-slf4j',           '~> 1.6.0'

  s.depend 'minitest',              '~> 2.2',       :dev

  s.assembly_version = '1.0'

  s.jars = %w[ core classic access ].
    map { |j| "logback-#{j}-#{ Logback::LOGBACK_VERSION }.jar" }

  # FIXME: s.rdoc_locations <<
  # "dekellum@rubyforge.org:/var/www/gforge-projects/rjack/logback"
end
