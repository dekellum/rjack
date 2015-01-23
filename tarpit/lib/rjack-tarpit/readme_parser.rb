#--
# Copyright (c) 2009-2015 David Kellum
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

require 'rjack-tarpit/base'

module RJack::TarPit

  # Helper mixin for deriving default spec properties from the README
  # (rdoc,txt) file
  module ReadmeParser

    # Parse the given README file, setting properties homepage,
    # summary, and description on self if possible.
    def parse_readme( file )

      in_desc = false
      desc = ""

      readme_file_open( file ) do |fin|
        fin.each do |line|
          if homepage.nil? && line =~ /^\s*\*\s*(http\S+)\s*$/
            self.homepage = $1
          elsif line =~ /^=/ # section header
            in_desc = ( line =~ /^=+\s*Description\s*$/i )
            # Stop at new section if we already have a description
            break unless desc.empty?
          elsif in_desc
            # Stop if empty line after description, or bullet (*) list
            break if ( !desc.empty? && line =~ /^\s*$/ ) || line =~ /^\s*\*/
            desc << line
          end
        end
      end

      desc = desc.
        gsub( /\s+/, ' ' ). #Simplify whitespace
        gsub( /\{([^\}]+)\}\[[^\]]*\]/, '\1' ). # Replace rdoc link \w anchor
        gsub( /(\S)\[\s*http:[^\]]*\]/, '\1' ). # Replace bare rdoc links
        strip.
        sub( /:$/, '.' ) # Replace a final ':', like when term. at list

      # Summary is first sentence if we find one, or entire desc otherwise
      if desc =~ /^(.+[!?:.])\s/
        self.summary = $1.strip
        self.description = desc # Use remainder for description
      else
        self.summary = desc
      end

    end

    private

    # Open, and test hook
    def readme_file_open( file, &block )
      File.open( file, 'r', &block )
    end

  end

end
