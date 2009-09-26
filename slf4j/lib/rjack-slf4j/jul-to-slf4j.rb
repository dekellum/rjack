require 'slf4j'
require 'slf4j/jul'

SLF4J.require_adapter( 'jul-to-slf4j' )

module SLF4J::JUL

  # Replace any existing configured root java.util.Logger Handlers with
  # the org.slf4j.bridge.SLF4JBridgeHandler
  def self.replace_root_handlers
    root_logger = root
    root_logger.handlers.each do |handler|
      root_logger.remove_handler( handler )
    end
    handler = Java::org.slf4j.bridge.SLF4JBridgeHandler.new

    root_logger.add_handler( handler )
  end

end
