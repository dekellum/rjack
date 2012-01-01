# -*- ruby -*- encoding: utf-8 -*-

$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), 'lib' ) )
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|

  s.version  = RJack::TarPit::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.summary = 'Glue for Maven in Rake.'

  s.description = <<-DESC
    Runs mvn package/install and links jars as needed to gem lib directory.
    Provides related utilities.
  DESC

  s.depend 'rake',            '~> 0.9.2'
  s.depend 'rdoc',            '~> 3.6'
  s.depend 'minitest',        '~> 2.3',       :dev

  if RUBY_PLATFORM =~ /java/
    s.depend 'rjack-maven',   '~> 3.0'

    # These are deps of test/zookeeper
    s.depend 'rjack-slf4j',   '~> 1.6.4',     :dev
    s.depend 'rjack-logback', '~> 1.2',       :dev

    s.platform = :java
  end

end
