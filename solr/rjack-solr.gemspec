# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-solr/base'

  s.version = RJack::Solr::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rjack-commons-codec', '~> 1.6.0'
  s.depend 'rjack-lucene',        '~> 3.6.0'
  s.depend 'rjack-jetty',         '~> 7.6.4'
  s.depend 'rjack-jetty-jsp',     '~> 7.6.4'
  s.depend 'rjack-httpclient-3',  '~> 3.1.5'
  s.depend 'hooker',              '~> 1.0.0'

  s.depend 'rjack-logback',       '~> 1.3',              :dev
  s.depend 'minitest',            '~> 2.2',              :dev

  s.assembly_version = '1.0'
  s.maven_strategy = :jars_from_assembly

  s.generated_files = Dir[ 'webapp/**/*' ]
end
