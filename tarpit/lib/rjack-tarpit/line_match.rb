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

module RJack::TarPit

  module LineMatchTaskDefiner

    # Regexp to use for first line of History file with version, date
    attr_accessor :history_regexp

    # Regexp to use for a valid/releasable date on History
    attr_accessor :history_date_regexp

    # Proc returning regexp given gem version as parameter, to use to
    # validate the version of the latest history entry.
    attr_accessor :history_version_regexp

    def initialize
      super

      @history_regexp         = /^==/
      @history_date_regexp    = /\([0-9\-]+\)$/
      @history_version_regexp = Proc.new { |v| / #{v} / }

      add_define_hook( :define_line_match_tasks )
    end

    def define_line_match_tasks

      if spec.history_file && history_regexp
        desc "Check that #{spec.history_file} has lastest version"
        task :check_history_version do
          test_line_match( spec.history_file,
                           history_regexp,
                           history_version_regexp.call( spec.version ) )
        end
        [ :gem, :tag, :push ].each { |t| task t => :check_history_version }
      end

      if spec.history_file && history_date_regexp
        desc "Check that #{spec.history_file} has a date for release"
        task :check_history_date do
          test_line_match( spec.history_file,
                           history_regexp,
                           history_date_regexp )
        end
        [ :tag, :push ].each { |t| task t => :check_history_date }
      end

    end

    # Test that all specified files have at least one line matching
    # line_regex, and that first line additionally matches (optional)
    # pass_line_regex.
    # ==== Parameters
    # files<Array(~)>:: List of files to test
    # line_regex<Regexp>:: Test first matching line
    # pass_line_regex:: Further test on match line (default: match all)
    # ==== Raises
    # RuntimeError:: on test failure.
    def test_line_match( files, line_regex, pass_line_regex = // )
      Array( files ).each do |mfile|
        found = false
        open( mfile ) do |mf|
          num = 0
          mf.each do |line|
            num += 1
            if line =~ line_regex
              found = true
              unless line =~ pass_line_regex
                raise( "%s:%d: %s !~ %s" %
                       [ mfile, num, line.strip, pass_line_regex.inspect ] )
              end
              break
            end
          end
        end
        unless found
          raise "#{mfile}: #{line_regex.inspect} not found"
        end
      end
    end

  end

end
