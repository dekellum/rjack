require 'hoe'

# Silly Hoe sets up DOT with rdoc unless this is set.
ENV['NODOT'] = "no thanks"

class TarPit
  VERSION = '1.0.0'

  # Specify gem project details, yielding hoe instance to block after setting
  # various defaults.
  def self.specify( name, &outer )
    Hoe.spec( name ) do |h|

      h.readme_file  =  'README.rdoc' if File.exist?(  'README.rdoc' )
      h.history_file = 'History.rdoc' if File.exist?( 'History.rdoc' )
      h.extra_rdoc_files = FileList[ '*.rdoc' ]

      outer.call( h )
    end
  end
end
