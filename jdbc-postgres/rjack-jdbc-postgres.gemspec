# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-jdbc-postgres/base'

  s.version = RJack::JDBCPostgres::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'minitest',              '~> 4.7.4',     :dev
  s.depend 'rdoc',                  '~> 4.0.1',     :dev

  s.generated_files = [
    "lib/#{s.name}/postgresql-#{RJack::JDBCPostgres::DRIVER_VERSION}.jdbc4.jar" ]
end
