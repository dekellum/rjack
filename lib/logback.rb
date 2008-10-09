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

# Jruby wrapper module for the SLF4J-compliant
# Logback[http://logback.qos.ch/] log writer.  Configuration of
# appenders and (dynamic) setting of logger output level is supported.

require 'rubygems'

gem( 'slf4j', '>=1.5.3.1' )
require 'slf4j'

require 'java'

require 'logback/version'

module Logback
  require_jar 'logback-core'
  require_jar 'logback-classic'

  import 'ch.qos.logback.classic.Level'
  import 'ch.qos.logback.core.ConsoleAppender'
  import 'ch.qos.logback.core.FileAppender'
  import 'ch.qos.logback.classic.PatternLayout'
  import 'ch.qos.logback.classic.joran.JoranConfigurator'

  # Wrapper for logback.classic.Logger
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
    def add( appender )
      @jlogger.addAppender( appender )
    end

    # Set additive flag (false means events stop at attached appender)
    def additive=( is_additive )
      @jlogger.additive = is_additive
    end
  end
  
  # Wrapper for logback.classic.LoggerContext
  class Context 
    
    DEFAULT_PATTERN="%date [%thread] %-5level %logger{35} - %msg %ex%n"

    def initialize( context )
      @jcontext = context 
      @default_layout = new_pattern_layout
    end

    # (Re-)configure[] Logback using the supplied block.
    #
    # :call-seq:
    #   configure { |context| ... } -> nil
    #
    def configure
      @jcontext.shutdownAndReset

      yield( self )

      start( @jcontext )
      nil
    end

    # Return the named logger
    def logger( name )
      Logger.new( @jcontext.getLogger( name ) )
    end

    # Synonym for logger(name)
    def [](name)
      logger( name )
    end

    # Return the special root Logger
    def root
      logger( "root" )
    end

    # Load the specified Logback (Joran) XML configuration file. This
    # would generally be used in lieu of the programmatic new_*
    # methods.
    def load_xml_config( file )
      cfger = JoranConfigurator.new
      cfger.context = @jcontext
      cfger.doConfigure( file )
    end

    # Create a console appender, optionally setting additional
    # attributes in block.
    #
    # :call-seq:
    #   new_console_appender                    -> ConsoleAppender
    #   new_console_appender { |appender| ... } -> ConsoleAppender
    #
    def new_console_appender
      out = ConsoleAppender.new

      set_appender_defaults( out )

      yield( out ) if block_given?

      start( out )
    end

    # Create a file appender, optionally setting additional
    # attributes in block.
    #
    # :call-seq:
    #   new_file_appender                    -> FileAppender
    #   new_file_appender { |appender| ... } -> FileAppender
    #
    def new_file_appender
      out = FileAppender.new

      set_appender_defaults( out )

      out.file = "out.log"
      out.append = true
      out.immediateFlush = true

      yield( out ) if block_given?

      start( out )
    end
  
    # Create a pattern layout with the specific pattern string,
    # optionally setting additional attributes in block.
    #
    # :call-seq:
    #   new_pattern_layout(pattern=DEFAULT_PATTERN)                  -> PatternLayout
    #   new_pattern_layout(pattern=DEFAULT_PATTERN) { |layout| ... } -> PatternLayout
    #
    def new_pattern_layout( pattern=DEFAULT_PATTERN )
      layout = PatternLayout.new
      layout.context = @jcontext
      layout.pattern = pattern

      yield( layout ) if block_given?
      
      start( layout )
    end

    def set_appender_defaults( out )
      out.context = @jcontext
      out.name = "DEFAULT"
      out.encoding = "UTF-8"  

      out.layout = @default_layout
      out
    end

    def start( lc )
      lc.start
      raise "#{lc.class.name} did not start" if ! lc.started?
      lc
    end

  end
  
  @@context = Context.new( SLF4J.linked_factory )

  def self.context
    @@context 
  end

  # Define matching level constants, ex: DEBUG = Level::DEBUG
  SLF4J::LEVELS.each do |l| 
    lvl = l.upcase; 
    module_eval( "#{lvl} = Level::#{lvl}" )
  end

end
