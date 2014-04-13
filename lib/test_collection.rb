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
      file_path = test_data[:file]
      test_name = find_test_name(test_data[:line])
      return nil if (test_name && ! test_name.match(/^test_/))

      TestCase.new(
        full_path: file_path,
        test_name: test_name
      )
    end.compact
  end

  def empty?
    tests.empty?
  end

  def size
    tests.size
  end

  def first
    tests.first
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

  def files
    @files ||= tests.map {|t| t.file }.uniq
  end

  def working_dirs
    @working_dirs ||= tests.map {|t| t.working_dir }.uniq
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

end
