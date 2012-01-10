# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'rjack-commons-pool/base'

  s.version = RJack::CommonsPool::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'minitest',              '~> 2.2',       :dev

  s.assembly_version = '1.0'

  s.jars = [ "commons-pool-#{ RJack::CommonsPool::POOL_VERSION }.jar" ]

  # FIXME: s.rdoc_locations <<
  # "dekellum@rubyforge.org:/var/www/gforge-projects/rjack/commons-pool"
end
