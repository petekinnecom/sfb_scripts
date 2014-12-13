class TestCollection

  MultipleWorkingDirectoriesError = Class.new(StandardError)

  attr_reader :tests, :query

  def initialize(tests_data=[], query: '')
    @query = query
    @tests = tests_data.map do |test_data|
      if test_data.is_a? TestCase
        test_data
      else
        test_data = {file: test_data} if test_data.is_a?(String)

        TestCase.new(
          full_path: test_data[:file],
          line: test_data[:line]
        )
      end
    end.compact
  end

  def empty?
    tests.empty?
  end

  def uniq!
    @tests = @tests.uniq {|e| "#{e.full_path} #{e.test_name} #{e.working_dir}" }
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

  def all?(&block)
    tests.all?(&block)
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

  def is_one_test_method?
    (size == 1) &&  tests.first.is_method?
  end

end
