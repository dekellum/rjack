# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.1'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-jetty/base'

  s.version = RJack::Jetty::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-slf4j',      '>= 1.6.5',  '< 1.8',  :dev
  s.depend 'rjack-logback',    '~> 1.2',              :dev
  s.depend 'minitest',         '~> 4.7.4',            :dev
  s.depend 'rdoc',             '~> 4.0.1',            :dev

  s.assembly_version = '1.0'

  s.jars = %w[ webapp xml servlet security server
               continuation http io util rewrite client ].
    map do |n|
      "jetty-%s-%s.%s.jar" %
        [ n, RJack::Jetty::JETTY_VERSION, RJack::Jetty::JETTY_BUILD ]
    end

  s.jars += [ "javax.servlet-api-%s.jar" %
              [ RJack::Jetty::SERVLET_API_VERSION ] ,
              "rjack-jetty-1.0.jar" ]

  s.generated_files = [ 'webapps/test.war' ]
end
