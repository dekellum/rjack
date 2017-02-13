#--
# Copyright (c) 2009-2017 David Kellum
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

  # New task generator given name matching <name>.gemspec in the
  # current directory. If block is given, yields self (err, actually
  # the BaseStrategy) to block and calls define_tasks upon exit.
  def self.new( name )

    load( "#{name}.gemspec", true )

    tp = BaseStrategy.new( last_spec )

    if block_given?
      yield tp
      tp.define_tasks
    end

    tp
  end

end
