#--
# Copyright (c) 2009-2011 David Kellum
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#++

require 'rubygems/package_task'

module RJack::TarPit

  module GemTaskDefiner

    # Should package create a tarball? (default: false)
    attr_accessor :need_tar

    # Should package create a zipfile? (default: false)
    attr_accessor :need_zip

    def initialize
      super

      @need_tar = false
      @need_zip = false

      add_define_hook( :define_new_gem_tasks )
    end

    def define_new_gem_tasks

      Gem::PackageTask.new( spec ) do |pkg|
        pkg.need_tar = @need_tar
        pkg.need_zip = @need_zip
      end

      desc 'Dump plain ruby Gem::Specification'
      task :debug_gem do
        puts spec.to_ruby
      end

    end

  end

end
