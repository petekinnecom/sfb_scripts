class TestCase
  TestDirectoryError = Class.new(StandardError)

  attr_reader :working_dir, :relative_path, :test_name, :full_path

  def initialize(full_path: raise, line: '')
    raise 'Bad Test File' unless full_path.match(/_test\.rb/)

    @test_name = test_name_from_grepped_line(line)
    @full_path = full_path
  end

  def working_dir
    @working_dir ||=
      if full_path.match(/^(.*)test\//)
        File.join(".", full_path.match(/^(.*)test\//)[1])
      else
        raise TestDirectoryError.new("Can't find test's working directory")
      end
  end

  def is_method?
    ! @test_name.nil?
  end

  def relative_path
    @relative_path ||= full_path.gsub(/^#{working_dir.gsub(/^\.\//, '')}/, '') || raise_file_path_error
  end

  def raise_file_path_error
    raise TestDirectoryError.new("Can't find test's relative path")
  end

  def test_name_from_grepped_line(line)
    return unless line && line.match(/^\s*def\s+test_/)
    @test_name = line.strip.gsub(/^\s*def\s+/, '').strip
  end
end
