require 'rjack-jetty'

module RJack::Jetty
  require_jar( 'jetty-client' )

  import 'org.eclipse.jetty.client.HttpClient'
end
