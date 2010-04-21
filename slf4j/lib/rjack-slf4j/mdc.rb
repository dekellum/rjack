#--
# Copyright (c) 2008-2010 David Kellum
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

require 'rjack-slf4j'

module RJack::SLF4J

  # Mapped Diagnostic Context support module
  #
  # Note that this optional module can only be loaded after a output
  # adapter has been loaded.  Otherwise the following output is
  # printed and Exception will be thrown:
  #
  #   SLF4J: Failed to load class "org.slf4j.impl.StaticMDCBinder".
  #   SLF4J: See http://www.slf4j.org/codes.html#no_static_mdc_binder for further details.
  #   java.lang.NoClassDefFoundError: org/slf4j/impl/StaticMDCBinder
  #
  module MDC

    # Get value associated with key, or nil.
    def self.[]( key )
      org.slf4j.MDC::get( key.to_s )
    end

    # Associate val with key, or remove key is value is nil.
    def self.[]=( key, val )
      if val
        org.slf4j.MDC::put( key.to_s, val.to_s )
      else
        org.slf4j.MDC::remove( key.to_s )
      end
    end
  end
end
