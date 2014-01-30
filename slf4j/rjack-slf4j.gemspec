# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-slf4j/base'

  s.version = RJack::SLF4J::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'minitest',              '~> 4.7.4',     :dev
  s.depend 'rdoc',                  '~> 4.0.1',     :dev

  def s.loaders
    RJack::SLF4J::ADAPTERS.flatten.compact - [ "jul-to-slf4j" ]
  end

  s.generated_files = s.loaders.map { |adp| "lib/#{s.name}/#{adp}.rb" }

  s.jars = ( [ 'slf4j-api' ] +
             RJack::SLF4J::ADAPTERS.map { |i,o| [ i, "slf4j-#{o}" ] } ).
    flatten.
    compact.
    map { |n| "#{n}-#{RJack::SLF4J::SLF4J_VERSION}.jar" }

  s.assembly_version = '1.0'
end
