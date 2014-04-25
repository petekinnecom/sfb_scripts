require_relative 'test_case'

class TestCollection

  MultipleWorkingDirectoriesError = Class.new(StandardError)

  def self.parse(grep_result)
    new(grep_result[:file], line: grep_result[:line]).parse
  end


  def self.from_file_path(file_path)
    new(file_path).from_file_path
  end

  attr_reader :tests

  def initialize(tests_data)
    @tests = tests_data.map do |test_data|
      create_test_case(test_data)
    end.compact
  end

  def empty?
    tests.empty?
  end

  def present?
    ! empty?
  end

  def size
    tests.size
  end

  def first
    tests.first
  end

  def [](*args)
    tests[*args]
  end

  def in_one_file?
    full_paths.size == 1
  end

  def in_one_engine?
    working_dirs.size == 1
  end

  def full_paths
    @full_paths ||= tests.map {|t| t.full_path }.uniq
  end

  def relative_paths
    @relative_paths ||= tests.map {|t| t.relative_path }.uniq
  end

  def working_dirs
    @working_dirs ||= tests.map {|t| t.working_dir }.uniq
  end

  def relative_paths_in(working_directory)
    tests.select {|t| t.working_dir == working_directory}.map {|t| t.relative_path }.uniq
  end

  def include_selenium?
    ! selenium_tests.empty?
  end

  def remove_selenium!
    @tests = tests - selenium_tests
  end

  def selenium_tests
    tests.select {|t| t.full_path.match(/selenium/)}
  end

  def working_dir
    raise MultipleWorkingDirectoriesError.new("Can't run tests for more than one engine") unless working_dirs.size == 1

    return working_dirs.first
  end

  private

  def find_test_name(grepped_line)
    return nil unless grepped_line
    grepped_line.strip.gsub(/^\s*def /, '').strip
  end

  def create_test_case(test_data)
    file_path = test_data[:file]
    test_name = find_test_name(test_data[:line])
    return nil if ! file_path.match(/_test\.rb/)
    return nil if (test_name && ! test_name.match(/^test_/))

    TestCase.new(
      full_path: file_path,
      test_name: test_name
    )
  end

end
