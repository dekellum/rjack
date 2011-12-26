# -*- ruby -*- encoding: utf-8 -*-

# Special case load required while we have a Gemfile for this test project.
# Not to worry, would normally just do:
# gem 'rjack-tarpit'
$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), '..', '..', 'lib' ) )

require 'rjack-tarpit/spec'

$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), 'lib' ) )

require 'rjack-zookeeper/base'

RJack::TarPit.specify do |s|
  s.version  = RJack::ZooKeeper::VERSION

  s.add_developer 'David Kellum', 'dek-oss@gravitext.com'

  s.maven_strategy = :jars_from_assembly
  #FIXME: move here:  s.assembly_version = 1.0

  s.depend 'rjack-slf4j',     '~> 1.6.4'
  s.depend 'minitest',        '~> 2.3',   :dev
  s.depend 'rjack-logback',   '~> 1.2',   :dev
end
