# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-solr/base'

  s.version = RJack::Solr::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-commons-codec', '~> 1.6.0'
  s.depend 'rjack-lucene',        '~> 4.1.0'
  s.depend 'rjack-jetty',         '>= 7.6.7', '< 9.1'
  s.depend 'rjack-jetty-jsp',     '>= 7.6.7', '< 9.1'
  s.depend 'rjack-httpclient-4',  '~> 4.2.1'
  s.depend 'rjack-zookeeper',     '~> 3.4.5'
  s.depend 'rjack-guava',         '~> 13.0'
  s.depend 'hooker',              '~> 1.0.1'
  s.depend 'rjack-slf4j',         '>= 1.6.5', '< 1.8'
  s.depend 'rjack-logback',       '~> 1.2'

  s.depend 'minitest',            '~> 2.2',   :dev

  s.assembly_version = '1.0'
  s.maven_strategy = :jars_from_assembly

  s.generated_files = Dir[ 'webapp/**/*' ]
end
