# -*- ruby -*- encoding: utf-8 -*-

$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), 'lib' ) )
require 'rjack-tarpit/spec'
$LOAD_PATH.shift

RJack::TarPit.specify do |s|

  s.version = RJack::TarPit::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rake',            '>= 0.9.2.2', '< 11'
  s.depend 'rdoc',            '>= 3.12',    '< 5'
  s.depend 'minitest',        '~> 4.7.4',     :dev

  if RUBY_PLATFORM =~ /java/
    s.depend 'rjack-maven',   '~> 3.0.4'

    # These are deps of test/zookeeper
    s.depend 'rjack-slf4j',   '~> 1.7.0',     :dev
    s.depend 'rjack-logback', '~> 1.5',       :dev

    s.platform = :java
  end

end
