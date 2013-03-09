# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-jdbc-postgres/base'

  s.version = RJack::JDBCPostgres::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'minitest',              '~> 2.2',       :dev

  s.generated_files = [
    "lib/#{s.name}/postgresql-#{RJack::JDBCPostgres::DRIVER_VERSION}.jdbc4.jar" ]
end
