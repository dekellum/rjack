# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-jms-spec/base'

  s.version = RJack::JMSSpec::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'minitest',              '~> 2.2',       :dev

  s.assembly_version = '1.0'

  s.jars = [ "geronimo-jms_%s_spec-%s.jar" %
             [ RJack::JMSSpec::JMS_VERSION,
               RJack::JMSSpec::GERONIMO_VERSION ] ]

end
