
require 'rubygems'

require 'jetty-jsp/base'



module JettyJsp
  include JettyJspBase

  gem 'jetty', "~> #{JETTY_VERSION}"
  require 'jetty'
  
  Dir.glob( File.join( JETTY_JSP_DIR, '*.jar' ) ).each { |jar| require jar }
end
