# -*- ruby -*- encoding: utf-8 -*-

require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'jproject/base'

  s.version  = JProject::VERSION

  s.add_developer 'David Kellum', 'dek-oss@gravitext.com'

  s.maven_strategy = :no_assembly

  s.depend 'minitest', '~> 2.3', :dev
end
