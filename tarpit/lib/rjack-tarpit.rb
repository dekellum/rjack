#--
# Copyright (c) 2009-2011 David Kellum
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

require 'rjack-tarpit/base'
require 'rjack-tarpit/spec'
require 'rjack-tarpit/base_strategy'

module RJack::TarPit

  # New task generator given name matching a spec name in the current
  # directory.
  def self.new( name )

    load "#{name}.gemspec"
    spec = last_spec

    if spec.maven_strategy == :jars_from_assembly
      require 'rjack-tarpit/jars_from_assembly'
      JarsFromAssembly.new( spec )
    else
      BaseStrategy.new( spec )
    end
  end

end
