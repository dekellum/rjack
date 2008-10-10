#--
# Copyright 2008 David Kellum
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You
# may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#++


require 'slf4j/version'
require 'java'

# Wrapper and core Logger compatible adapter for the
# SLF4J[http://www.slf4j.org/] logging interface.
module SLF4J

  def self.current_loader
    java.lang.Thread::current_thread.context_class_loader
  end

  SLF4J_LOADER = current_loader

  def self.require_jar( name )
    #FIXME: Doesn't appear to catch what we would hope it catches.
    if current_loader != SLF4J_LOADER
      $stderr.puts( "WARNING: Loading #{name} in different class loader " + 
        "from where slf4j-api.jar is loaded." )
    end
    require File.join( SLF4J_DIR, "#{name}-#{ SLF4J_VERSION }.jar" )

  end

  require_jar 'slf4j-api'
  
  LEVELS = %w{ trace debug info warn error }

  # Wrapper around org.slf4j.Logger (JLogger)
  class Logger
    attr_reader :name

    def initialize( name )
      @name = name
      @logger = org.slf4j.LoggerFactory.getLogger( @name )
    end
   
    # Define logging methods for each level: debug(), error(), etc.
    LEVELS.each do |lvl|  
      module_eval( %Q{

        def #{lvl}?
          @logger.is#{lvl.capitalize}Enabled
        end

        def #{lvl}( msg=nil )
          msg = yield if ( block_given? && #{lvl}? )
          @logger.#{lvl}( msg.to_s ) unless msg.nil?
         end

      } )
    end

    # Alias fatal to error for Logger compatibility
    alias_method :fatal, :error
    alias_method :fatal?, :error?
  end
  
  # Get Logger by name
  def logger( name = self.class.name ) 
    Logger.new( name )
  end
  module_function :logger


  # The Classpath linked ILoggerFactory instance.
  def self.linked_factory
     org.slf4j.LoggerFactory.getILoggerFactory
  end
  
end
