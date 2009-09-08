#--
# Copyright (C) 2008-2009 David Kellum
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
require 'java'
require 'slf4j'

require 'logback/base'

# Jruby wrapper module for the Logback[http://logback.qos.ch/] log writer.
# Programmatic configuration and setting of logger output levels is supported.
#
# == Examples
#
# === High level configuration
#
#   require 'logback'
#
#   Logback.config_console( :thread => true, :level => Logback:INFO )
#
# === Low level configuration
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
# similar fashion externally.  Consider providing a patch to the
# rjack[http://rubyforge.org/projects/rjack] project with desired
# extensions.
#
module Logback

  # Load logback jar.
  def self.require_jar( name )
    require File.join( LOGBACK_DIR, "#{name}-#{ LOGBACK_VERSION }.jar" )
  end

  require_jar 'logback-core'
  require_jar 'logback-classic'

  # ch.qos.logback.classic.Level
  Level = Java::ch.qos.logback.classic.Level

  # Level::TRACE
  TRACE = Level::TRACE

  # Level::DEBUG
  DEBUG = Level::DEBUG

  # Level::INFO
  INFO  = Level::INFO

  # Level::WARN
  WARN  = Level::WARN

  # Level::ERROR
  ERROR = Level::ERROR

  DEFAULT_PATTERN = "%date [%thread] %-5level %logger{35} - %msg %ex%n" #:nodoc:

  @@context = SLF4J.linked_factory

  # Returns the LoggerContext
  def self.context
    @@context
  end

  # Utility mixin of Logback ch.qos.logback.core.spi.LifeCycle instances
  module Util
    # Start, raise if not started
    def self.start( lifecycle_obj )
      lifecycle_obj.start
      raise "#{lifecycle_obj.class.name} did not start" if ! lifecycle_obj.started?
    end
  end

  # Wrapper for
  # ch.qos.logback.classic.Logger[http://logback.qos.ch/apidocs/ch/qos/logback/classic/Logger.html]
  class Logger

    # Initialize given ch.qos.logback.classic.Logger
    def initialize( jlogger )
      @jlogger = jlogger
    end

    # Set output level
    # ==== Parameters
    # :level<Level>:: New output Level.
    def level=( level )
      @jlogger.level = level
    end

    # Add appender to this logger
    # ==== Parameters
    # :appender<ch.qos.logback.core.Appender>:: Appender
    def add_appender( appender )
      @jlogger.add_appender( appender )
    end

    # Set additive flag ( false means events stop at attached appender )
    def additive=( is_additive )
      @jlogger.additive = is_additive
    end
  end

  # ch.qos.logback.classic.joran.JoranConfigurator
  JoranConfigurator = Java::ch.qos.logback.classic.joran.JoranConfigurator

  # Load the specified Logback (Joran) XML configuration file. Should be
  # called within a configure {...} block.
  def self.load_xml_config( file )
    cfger = JoranConfigurator.new
    cfger.context = @@context
    cfger.doConfigure( file )
  end

  # ch.qos.logback.classic.PatternLayout
  JPatternLayout = Java::ch.qos.logback.classic.PatternLayout

  # Extends
  # ch.qos.logback.classic.PatternLayout[http://logback.qos.ch/apidocs/ch/qos/logback/classic/PatternLayout.html]
  # with a block initializer.
  class PatternLayout < JPatternLayout

    # Sets context and pattern, yields self to block, and calls self.start
    def initialize( pattern=DEFAULT_PATTERN )
      super()
      self.context = Logback.context
      self.pattern = pattern
      yield( self ) if block_given?
      Util.start( self )
    end
  end

  # Utility implementation mixin for Appenders.
  module AppenderUtil
    @@default_layout = Logback::PatternLayout.new

    # Set appender defaults.
    def set_defaults
      self.context = Logback.context
      self.name = self.class.name
      self.layout = @@default_layout
    end

    # Yield to block, then start.
    def finish( &block )
      block.call( self ) unless block.nil?
      Util.start( self )
    end
  end

  # ch.qos.logback.core.ConsoleAppender
  JConsoleAppender = Java::ch.qos.logback.core.ConsoleAppender

  # Extends
  # ch.qos.logback.core.ConsoleAppender[http://logback.qos.ch/apidocs/ch/qos/logback/core/ConsoleAppender.html]
  # with a block initializer.
  class ConsoleAppender < JConsoleAppender
    include AppenderUtil

    # Sets context, default name and layout, yields self to block, and
    # calls self.start
    def initialize( &block )
      super()
      set_defaults
      finish( &block )
    end
  end

  # ch.qos.logback.core.FileAppender
  JFileAppender = Java::ch.qos.logback.core.FileAppender

  # Extends
  # ch.qos.logback.core.FileAppender[http://logback.qos.ch/apidocs/ch/qos/logback/core/FileAppender.html]
  # with a block initializer.
  #
  # Note that if buffered (immediate_flush = false, buffer_size > 0),
  # you will need to +stop+ the appender before exiting in order to
  # flush/close the log.  Calling:
  #
  #   Logback.configure {}
  #
  # Will also result in the log being flushed and closed.
  #
  class FileAppender < JFileAppender
    include AppenderUtil

    # Sets defaults, yields self to block, and calls self.start
    def initialize( file_name, append = true, &block )
      super()
      set_defaults
      self.file = file_name
      self.append = append
      self.immediate_flush = true #default
      self.encoding = "UTF-8"
      finish( &block )
    end
  end

  # Configure Logback with the specified block. The Logback context is
  # +reset+, yielded to block, and then started after return
  # from the block.
  def self.configure
    @@context.reset

    yield context

    Util.start( context )
    nil
  end

  # Configure a single ConsoleAppender using options hash.
  # ==== Options
  # :stderr:: Output to standard error? (default: false)
  # :full:: Output full date? (default: false, milliseconds)
  # :thread:: Output thread name? (default: false)
  # :level<Level>:: Set root level (default: INFO)
  # :lwidth<~to_s>:: Logger width (default: :full ? 35 : 30)
  # :mdc<String|Array[String]>:: One or more Mapped Diagnostic Context keys
  # :mdc_width<~to_s}:: MDC width (default: unspecified)
  def self.config_console( options = {} )
    configure do
      console = Logback::ConsoleAppender.new do |a|
        a.target = "System.err" if options[ :stderr ]
        a.layout = Logback::PatternLayout.new do |layout|
          pat = [ options[ :full ] ? '%date' : '%-4r' ]
          pat << '[%thread]' if options[ :thread ]
          pat << '%-5level'

          w = ( options[ :lwidth ] || ( options[ :full ] ? 35 : 30 ) )
          pat << "%logger{#{w}}"

          mdcs = options[ :mdc ].to_a.map { |k| "%X{#{k}}" }
          unless mdcs.empty?
            mp = ( '\(' + mdcs.join(',') + '\)' )
            mw = options[ :mdc_width ]
            mp = "%-#{mw}(#{mp})" if mw
            pat << mp
          end

          pat += [ '-', '%msg' '%ex%n' ]
          layout.pattern = pat.join( ' ' )
        end
      end
      Logback.root.add_appender( console )
      Logback.root.level = options[ :level ] || INFO
    end
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
