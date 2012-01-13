# -*- ruby -*-

gems = %w[ tarpit
           slf4j
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

subtasks = %w[ clean install_deps test gem docs tag install publish_docs push ]

task :default => :test

# Common task idiom for the common distributive subtasks
sel_tasks = Rake.application.top_level_tasks
sel_tasks << 'test' if sel_tasks.delete( 'default' )

sel_subtasks = ( subtasks & sel_tasks )

task :distribute do
  Rake::Task[ :multi ].invoke( sel_subtasks.join(' ') )
end

subtasks.each do |sdt|
  desc ">> Run '#{sdt}' on all gem sub-directories"
  task sdt => :distribute
end

desc "Run multi['task1 tasks2'] tasks over all sub gems"
task( :multi, :subtasks ) do |t,args|
  stasks = args.subtasks.split
  gems.each do |dir|
    Dir.chdir( dir ) do
      puts ">> cd #{dir}"
      sh( $0, *stasks )
    end
  end
end

desc "Run multish['shell command'] over all sub gem dirs"
task( :multish, :subtasks ) do |t,args|
  gems.each do |dir|
    Dir.chdir( dir ) do
      puts ">> cd #{dir}"
      sh( args.subtasks )
    end
  end
end
