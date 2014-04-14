class TestRunner

  attr_reader :shell
  def initialize(env)
    @shell = env[:shell]
  end

  def run_method(test)
    test_runner = named_test_runner(test.working_dir)

    shell.exec("#{test_runner} #{test.relative_path} --name=#{test.test_name}", dir: test.working_dir)
  end

  def run_files(tests)
    test_runner = test_collection_runner(tests.working_dir)
    test_files = tests.relative_paths.join(' ')

    shell.exec("#{test_runner} #{test_files}", dir: tests.working_dir)
  end

  private

  def test_runner_type(working_dir)
    if shell.run("ls bin", dir: working_dir).split("\n").include? 'testunit'
      :spring
    else
      :ruby
    end
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
      "ruby -I test -e \"ARGV.each{|f| require Dir.pwd + '/' + f}\""
    end
  end

end
