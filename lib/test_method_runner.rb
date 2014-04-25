require_relative 'test_runner'
require_relative 'shell_runner'

class TestMethodRunner

  def self.run(regex, env)
    new(env).run(regex)
  end

  attr_reader :regex, :repo, :shell, :test_runner
  def initialize(env)
    @repo = env[:repo]
    @shell = env[:shell]
    @test_runner = env[:test_runner]
  end

  def run(regex)
    @regex = regex

    if tests.empty?
      shell.notify "Could not find matching test method."
      return false
    elsif tests.size == 1
      test_runner.run_method(tests.first)
    elsif tests.in_one_file?
      shell.notify "Multiple matches in same file. Running that file."
      test_runner.run_files(tests)
    elsif tests.in_one_engine? && tests.full_paths.size < 4 # hack: maybe should ask here?
      shell.notify "Multiple matches across files in same engine. Running those files."
      test_runner.run_files(tests)
    else
      shell.warn 'Found too many tests:'
      tests[0..10].each {|t| shell.notify "#{t.full_path}: #{t.test_name}" }
      shell.notify '...'
      exit
    end
  end

  def tests
    @test_collection ||= TestCollection.new(find_tests_by_name)
  end

  def find_tests_by_name
    test_def_regex = "^\s*def .*#{regex}.*"
    begin
      return repo.grep(test_def_regex, file_pattern: '*_test.rb')
    rescue ShellRunner::CommandFailureError
      # git grep exits with 1 if no results
      return []
    end
  end

end
