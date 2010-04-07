# -*- ruby -*-

gems = %w[ tarpit
           slf4j
           logback
           commons-pool
           commons-codec
           commons-dbcp
           commons-dbutils
           httpclient-3
           httpclient-4
           jdom
           jetty
           jetty-jsp
           rome
           jets3t ]

desc "Run multi['task1 tasks2'] tasks over all sub gems"
task( :multi, :subtasks ) do |t,args|
  subtasks = args.subtasks.split
  gems.each do |dir|
    Dir.chdir( dir ) do
      puts ">> cd #{dir}"
      sh( "jrake", *subtasks )
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

desc "Aggregated javadocs via Maven"
task :javadoc do
  sh( "mvn javadoc:aggregate" )
end

desc "Deferred dependencies for rdoc"
task :rdocdeps do
  require 'rubygems'
  require 'rdoc'
end

task :rdoc   => [ :rdocdeps ]
task :rerdoc => [ :rdocdeps ]

require 'rake/rdoctask'

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_dir = "doc" # FIXME: www/_site/rdoc?
  rd.title = "RJack RDoc"
  rd.options << "--charset=UTF-8"
  rd.rdoc_files.include( "README.rdoc" )
  gems.each do |gem|
    rd.rdoc_files.include( "#{gem}/README.rdoc",
                           "#{gem}/History.rdoc",
                           "#{gem}/lib/**/*.rb" )
  end
end

require 'rubygems'
require 'yard'
require 'yard/rake/yardoc_task'

YARD::Rake::YardocTask.new do |t|
  t.files  << "README.rdoc"

  gems.each do |gem|
    t.files += [ "#{gem}/README.rdoc",
                 "#{gem}/History.rdoc",
                 "#{gem}/lib/**/*.rb" ]
  end
end
