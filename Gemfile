# -*- ruby -*-

source :rubygems

# tarpit, maven aren't included here, as we want to use release
# versions for building

gems = %w[ slf4j
           logback
           async-httpclient
           commons-pool
           commons-codec
           commons-dbcp
           commons-dbutils
           httpclient-3
           httpclient-4
           icu
           jackson
           jdom
           jetty
           jetty-jsp
           rome
           jets3t
           xerces
           nekohtml
           protobuf
           jms-spec
           jms
           mina
           qpid-client ]

bdir = File.dirname( __FILE__ )

gems.each do |sname|
  gname = 'rjack-' + sname

  #FIXME: Drop conditional once we are done converting.
  if File.exist? File.join( bdir, sname, gname + ".gemspec" )
    gemspec :path => sname, :name => gname
  end
end
