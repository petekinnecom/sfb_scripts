require_relative 'shell_runner'

class TestRunner

  attr_reader :shell, :all_engines_param
  def initialize(env)
    @shell = env[:shell]
    @all_engines_param = env[:all_engines]
  end

  def run_method(test)
    test_runner = named_test_runner(test.working_dir)

    shell.exec("#{test_runner} #{test.relative_path} --name=#{test.test_name}", dir: test.working_dir)
  end

  def run_files(tests)
    begin
      test_runner = test_collection_runner(tests.working_dir)
      test_files = tests.relative_paths.join(' ')

      shell.exec("#{test_runner} #{test_files}", dir: tests.working_dir)
    rescue TestCollection::MultipleWorkingDirectoriesError => e
      if run_across_engines?
        run_across_engines(tests)
      end
    end
  end

  private

  def run_across_engines(tests)
    shell.notify "\nfinding test runners"
    tests.working_dirs.each do |engine_dir|
      test_files = tests.relative_paths_in(engine_dir).join(' ')
      test_runner = test_collection_runner(engine_dir)

      shell.enqueue("#{test_runner} #{test_files}", dir: engine_dir)
    end
    shell.exec_queue
  end

  def test_runner_type(working_dir)
    if shell.run("ls bin", dir: working_dir).split("\n").include? 'testunit'
      :spring
    else
      :ruby
    end
  rescue ShellRunner::CommandFailureError
    :ruby
  end

  def named_test_runner(working_dir)
    if test_runner_type(working_dir) == :spring
      "bin/testunit"
      "ruby -I test"
    else
      "ruby -I test"
    end
  end

  def test_collection_runner(working_dir)
    if test_runner_type(working_dir) == :spring
      "bin/testunit"
      "ruby -I test"
    else
      %{ruby -I test -e 'ARGV.each { |file| require(Dir.pwd + "/" + file) }'}
    end
  end

  def run_across_engines?
    all_engines_param || shell.confirm?("Test files are in multiple engines.  Run them all?")
  end

end
