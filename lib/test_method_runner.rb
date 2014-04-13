require_relative 'test_runner'

class TestMethodRunner

  def self.run(regex, shell,  repo)
    new(regex, shell, repo).run
  end

  attr_reader :regex, :repo, :shell
  def initialize(regex, shell, repo)
    @regex = regex
    @repo = repo
    @shell = shell
  end

  def run
    if tests.empty?
      return false
    elsif tests.size == 1
      TestRunner.run_method(tests.first)
    elsif tests.in_one_file?
      TestRunner.run_files(tests)
    elsif tests.in_one_engine? && tests.full_paths.size < 4
      TestRunner.run_files(tests)
    else
      puts 'Found too many tests:'
      tests[0..10].each {|t| puts "#{t[:working_dir]}#{t[:file]}: #{t[:test]}" }
      puts '...'
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
