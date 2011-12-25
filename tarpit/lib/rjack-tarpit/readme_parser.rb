require 'rjack-tarpit/base'

module RJack::TarPit

  module ReadmeParser

    def parse_readme( file )

      in_desc = false
      desc = ""

      File.open( file, 'r' ) do |fin|
        fin.each do |line|
          if homepage.nil? && line =~ /^\s*\*\s*(http\S+)\s*$/
            self.homepage = $1
          elsif line =~ /^=/ # section header
            in_desc = ( line =~ /^=+\s*Description\s*$/ )
            # Stop at new section if we already have a description
            break unless desc.empty?
          elsif in_desc
            # Stop if empty line after description, or bullet (*) list
            break if ( !desc.empty? && line =~ /^\s*$/ ) || line =~ /^\s*\*/
            desc << line
          end
        end
      end

      sentences = desc.
        gsub( /\s+/, ' ' ). #Simplify whitespace
        gsub( /\{([^\}]+)\}\[[^\]]*\]/, '\1' ). #Replace rdoc link with its text
        split( /[!?:.]\s/ )

      self.summary     = sentences[0]           + '.' if sentences.length > 0
      self.description = sentences.join( '. ' ) + '.' if sentences.length > 1
    end

  end

end
