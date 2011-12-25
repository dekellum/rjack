# -*- ruby -*- encoding: utf-8 -*-

require 'rjack-tarpit/spec'

$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), 'lib' ) )

require 'jproject/base'

RJack::TarPit.specify do |s|

  s.name     = 'jproject'
  s.version  = JProject::VERSION
  s.homepage = 'http://rjack.rubyforge.org/tarpit'

  s.add_developer 'David Kellum', 'dek-oss@gravitext.com'

  s.summary = 'Simple Java Test Project.'

  s.description = <<-DESC
      Project with a maven built java jar included
  DESC

  s.maven_strategy = :no_assembly

  s.depend 'minitest', '~> 2.3', :dev

end
