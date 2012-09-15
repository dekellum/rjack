# -*- ruby -*- encoding: utf-8 -*-

$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), 'lib' ) )
require 'rjack-tarpit/spec'
$LOAD_PATH.shift

RJack::TarPit.specify do |s|

  s.version = RJack::TarPit::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'rake',            '~> 0.9.2', '>= 0.9.2.2'
  s.depend 'rdoc',            '~> 3.12'
  s.depend 'minitest',        '~> 2.10',      :dev

  if RUBY_PLATFORM =~ /java/
    s.depend 'rjack-maven',   '~> 3.0.3'
    s.depend 'jruby-openssl', '~> 0.7.4'

    # These are deps of test/zookeeper
    s.depend 'rjack-slf4j',   '>= 1.6.5', '< 1.8', :dev
    s.depend 'rjack-logback', '~> 1.2',            :dev

    s.platform = :java
  end

end
