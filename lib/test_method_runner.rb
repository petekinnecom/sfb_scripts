require_relative 'test_runner'

class TestMethodRunner

  def self.run(regex,shell,  repo)
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
    elsif only_one_method_found
      TestRunner.run_method(tests.first)
    elsif all_in_one_file?
      TestRunner.run_file(tests.first)
    elsif all_in_one_engine? && test_files.size < 4
      TestRunner.run_files(tests_for_running)
    else
      puts 'Found too many tests:'
      tests[0..10].each {|t| puts "#{t[:working_dir]}#{t[:file]}: #{t[:test]}" }
      puts '...'
      exit
    end
  end

  def tests
    @tests ||= find_tests_by_name
  end

  def only_one_method_found
    tests.size == 1
  end

  def all_in_one_file?
    test_files.size == 1
  end

  def test_files
    @test_files ||= tests.map {|t| t[:full_path]}.uniq
  end

  def all_in_one_engine?
    tests_by_engine.keys.size == 1
  end

  def tests_for_running
    {
      working_dir: tests_by_engine.keys.first,
      files: tests_by_engine.values.first,
    }
  end

  def tests_by_engine
    #HOLY HACK BATMAN
    @tests_by_engine ||= {}.tap do |tbe|
      tests.each do |test|
        tbe[test[:working_dir]] ||= []
        tbe[test[:working_dir]] << test[:file] unless tbe[test[:working_dir]].include? test[:file]
      end
    end
  end

  def find_tests_by_name
    test_def_regex = "def .*#{regex}.*"
    begin
      results = repo.grep(test_def_regex, file_pattern: '*_test.rb')
    rescue ShellRunner::CommandFailureError
      # git grep exits with 1 if no results
      return []
    end

    tests = results.map do |result|
      TestCollection.parse(result)
    end.compact
  end

end
