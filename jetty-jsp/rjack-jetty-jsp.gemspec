# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-jetty-jsp/base'

  s.version = RJack::Jetty::Jsp::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-jetty',      "~> #{RJack::Jetty::Jsp::JETTY_VERSION}.0"

  s.depend 'minitest',         '~> 2.2',                :dev
  s.depend 'rjack-slf4j',      '>= 1.5.8',  '< 1.7',    :dev

  s.maven_strategy = :jars_from_assembly
  s.assembly_version = '1.0'

  s.generated_files = [ 'webapps/test.war' ]
end
