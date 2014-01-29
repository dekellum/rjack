# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-rome/base'

  s.version = RJack::ROME::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-jdom',            '~> 1.1.0'
  s.depend 'minitest',              '~> 4.7.4',     :dev
  s.depend 'rdoc',                  '~> 4.0.1',     :dev

  s.assembly_version = '1.0'

  s.jars = [ "rome-#{ RJack::ROME::ROME_VERSION }.jar" ]
end
