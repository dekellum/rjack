# -*- ruby -*- encoding: utf-8 -*-

cwd = File.dirname( __FILE__ )
$LOAD_PATH.unshift( File.join( cwd, 'lib' ),
                    File.join( cwd, '..', '..', 'lib' ) )

require 'rjack-tarpit/spec'

require 'jproject/base'

RJack::TarPit.specify do |s|
  s.name     = 'tarpit-test-jproject'
  s.version  = JProject::VERSION
  s.homepage = 'http://rjack.rubyforge.org/tarpit'

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.summary = 'Simple Java Test Project.'

  s.description = <<-DESC
      Project with a maven built java jar included
  DESC

  s.platform = :java

  s.extra_deps += [ [ 'rjack-slf4j', '~> 1.6' ] ]

  s.extra_dev_deps += [ [ 'minitest',      '~> 2.3' ],
                        [ 'rjack-logback', '~> 1.2' ] ]
end
