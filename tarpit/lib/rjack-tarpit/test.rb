module RJack::TarPit

  module TestTaskDefiner

    # Proc for setting Rake TestTask options
    # (default: nil, no-op)
    attr_accessor :test_task_config

    # Support same options as Rake::TestTask, plus tarpit's own
    # :mini_in_proc (default) option, which loads minitest tests and
    # runs in (rake) process.
    attr_accessor :test_loader

    def initialize
      super

      @test_loader = :mini_in_proc
      @test_task_config = nil

      add_define_hook( :define_test_tasks )
    end

    def define_test_tasks

      if test_loader == :mini_in_proc

        desc "Run minitest tests (in rake process)"
        task :test do |t,args|
          require 'minitest/unit'

          MiniTest::Unit.class_eval do
            def self.autorun
              # disable autorun, as we are running ourselves
            end
          end

          FileList[ "test/test*.rb" ].each { |f| load f }

          MiniTest::Unit.new.run( ( ENV['TESTOPTS'] || '' ).split )
        end

     else

        require 'rake/testtask'

        Rake::TestTask.new do |t|
          t.loader = test_loader
          test_task_config.call( t ) if test_task_config
        end

      end

    end

  end

end
