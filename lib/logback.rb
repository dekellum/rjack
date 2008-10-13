#--
# Copyright (C) 2008 David Kellum
#
# Logback Ruby is free software: you can redistribute it and/or
# modify it under the terms of the 
# {GNU Lesser General Public License}[http://www.gnu.org/licenses/lgpl.html] 
# as published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Logback Ruby is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#++

require 'rubygems'

gem( 'slf4j', '>=1.5.3.1' )
require 'slf4j'

require 'java'

require 'logback/base'

# Jruby wrapper module for the Logback[http://logback.qos.ch/] log writer.  
# Programmatic configuration and setting of logger output levels is supported.
#
# == Example
#
# Logback configuration:
#
#   require 'slf4j' 
#   require 'logback'
#
#   log = SLF4J[ 'example' ]
#   log.info "About to reconfigure..."
#
#   Logback.configure do
#     console = Logback::ConsoleAppender.new do |a|
#       a.target = "System.err"
#       a.layout = Logback::PatternLayout.new do |p|
#         p.pattern = "%r %-5level %logger{35} - %msg %ex%n"
#       end
#     end 
#     Logback.root.add_appender( console )
#     Logback.root.level = Logback::INFO
#   end
#
#   # Adjust output levels (also works outside of configure )
#   Logback[ 'example' ].level = Logback::DEBUG
#
#   log.debug "...after reconfigure."
#
# Configure with Logback XML configuration: 
#
#   Logback.configure do
#     Logback.load_xml_config( 'sample-logback.xml' )
#   end
#
# == Programmatic Configuration Support
#
# Logback java classes implement interfaces +LifeCycle+ and
# +ContextAware+ for configurability with Joran (XML). To simplify
# configuration in ruby, the following classes have been extended:
#
# * ConsoleAppender
# * FileAppender
# * PatternLayout
#
# The extensions provide a block initializer which sets sensible
# defaults, yields to a block for customization, and then calls
# +start+.  Logback provides many other components not yet extended in
# this way.  These can be created directly and or extended in a
# similar fashion externally.  Providing providing a patch to the
# jrack[http://rubyforge.org/projects/rjack] project with any desired
# extensions.
#
module Logback
  include LogbackBase

  def self.require_jar( name )
    require File.join( LOGBACK_DIR, "#{name}-#{ LOGBACK_VERSION }.jar" )
  end

  require_jar 'logback-core'
  require_jar 'logback-classic'

  import 'ch.qos.logback.classic.Level'

  TRACE = Level::TRACE
  DEBUG = Level::DEBUG
  INFO  = Level::INFO 
  WARN  = Level::WARN  
  ERROR = Level::ERROR

  DEFAULT_PATTERN = "%date [%thread] %-5level %logger{35} - %msg %ex%n"

  @@context = SLF4J.linked_factory

  # Returns the LoggerContext 
  def self.context
    @@context 
  end

  module Util
    def self.start( lifecycle_obj )
      lifecycle_obj.start
      raise "#{lifecycle_obj.class.name} did not start" if ! lifecycle_obj.started?
    end
  end 

  # Wrapper for 
  # ch.qos.logback.classic.Logger[http://logback.qos.ch/apidocs/ch/qos/logback/classic/Logger.html]
  class Logger
    def initialize( jlogger )
      @jlogger = jlogger
    end

    # Set output level to specified constant (DEBUG,INFO,...)
    def level=( level )
      #FIXME: LogBack bug: level = nil
      @jlogger.level = level
    end

    # Add appender to this logger
    def add_appender( appender )
      @jlogger.add_appender( appender )
    end

    # Set additive flag ( false means events stop at attached appender )
    def additive=( is_additive )
      @jlogger.additive = is_additive
    end
  end
  
  import 'ch.qos.logback.classic.joran.JoranConfigurator'

  # Load the specified Logback (Joran) XML configuration file. Should be
  # called within a configure {...} block.
  def self.load_xml_config( file )
    cfger = JoranConfigurator.new
    cfger.context = @@context
    cfger.doConfigure( file )
  end

  import( 'ch.qos.logback.classic.PatternLayout' ) { 'JPatternLayout' }

  # Extends 
  # ch.qos.logback.classic.PatternLayout[http://logback.qos.ch/apidocs/ch/qos/logback/access/PatternLayout.html] 
  # with a block initializer. 
  class PatternLayout < JPatternLayout

    # Sets context and pattern, yields self to block, and calls self.start
    #
    # :call-seq:
    #   new(pattern=DEFAULT_PATTERN)                -> PatternLayout
    #   new(pattern=DEFAULT_PATTERN) { |self| ... } -> PatternLayout
    #
    def initialize( pattern=DEFAULT_PATTERN )
      super()
      self.context = Logback.context
      self.pattern = pattern
      yield( self ) if block_given?
      Util.start( self )
    end
  end

  module AppenderUtil
    @@default_layout = Logback::PatternLayout.new

    def set_defaults
      self.context = Logback.context
      self.name = self.class.name
      self.layout = @@default_layout
    end
    
    def finish( &block )
      block.call( self ) unless block.nil?
      Util.start( self )
    end
  end

  import( 'ch.qos.logback.core.ConsoleAppender' ) { 'JConsoleAppender' }

  # Extends 
  # ch.qos.logback.core.ConsoleAppender[http://logback.qos.ch/apidocs/ch/qos/logback/core/ConsoleAppender.html]
  # with a block initializer. 
  class ConsoleAppender < JConsoleAppender
    include AppenderUtil
    
    # Sets context, default name and layout, yields self to block, and
    # calls self.start
    #
    # :call-seq:
    #   new()                -> ConsoleAppender
    #   new() { |self| ... } -> ConsoleAppender
    #
    def initialize( &block )
      super()
      set_defaults
      finish( &block )
    end
  end
  
  import( 'ch.qos.logback.core.FileAppender' ) { 'JFileAppender' }

  # Extends 
  # ch.qos.logback.core.FileAppender[http://logback.qos.ch/apidocs/ch/qos/logback/core/FileAppender.html]
  # with a block initializer. 
  class FileAppender < JFileAppender
    include AppenderUtil

    # Sets defaults, yields self to block, and calls self.start
    #
    # :call-seq:
    #   new(file_name,append = true)                -> FileAppender
    #   new(file_name,append = true) { |self| ... } -> FileAppender
    #
    def initialize( file_name, append = true, &block )
      super()
      set_defaults
      self.file = file_name
      self.append = append
      self.immediateFlush = true #default
      self.encoding = "UTF-8"  
      finish( &block )
    end
  end

  # Configure Logback with the specified block. The Logback context is
  # +shutdownAndReset+ before yielding, and then started after return
  # from the block.
  #
  # :call-seq:
  #   configure { |context| ... } -> nil
  #
  def self.configure
    @@context.shutdown_and_reset

    yield( context )

    Util.start( context )
    nil
  end

  # Returns the named Logger
  def self.logger( name )
    Logger.new( @@context.getLogger( name ) )
  end

  # Synonym for logger(name)
  def self.[](name)
    logger( name )
  end

  # Returns the special "root" Logger
  def self.root
    logger( "root" )
  end

end
