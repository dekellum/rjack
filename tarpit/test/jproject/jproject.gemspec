# -*- ruby -*- encoding: utf-8 -*-

require 'rjack-tarpit/spec'

$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), 'lib' ) )

require 'jproject/base'

RJack::TarPit.specify do |s|
  s.version  = JProject::VERSION

  s.add_developer 'David Kellum', 'dek-oss@gravitext.com'

  s.maven_strategy = :no_assembly

  s.depend 'minitest', '~> 2.3', :dev
end
