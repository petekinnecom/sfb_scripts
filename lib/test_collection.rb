require_relative 'test_case'

class TestCollection
  TestDirectoryError = Class.new(StandardError)

  def self.parse(grep_result)
    new(grep_result[:file], line: grep_result[:line]).parse
  end

  def self.from_file_path(file_path)
    new(file_path).from_file_path
  end


  attr_reader :file_path, :line

  def initialize(file_path, line: '')
    @file_path = file_path
    @line = line
  end

  def from_file_path
    raise TestDirectoryError.new("Can't find test's working directory") if working_dir.nil?

    raise TestDirectoryError.new("Can't find test's relative path") if relative_file_path.nil?

     TestCase.new(
      working_dir: working_dir,
      file: relative_file_path,
      test_name: test_name,
      full_path: file_path,
    )
  end

  def parse
    return nil unless test_name.match(/^test_/)

    raise TestDirectoryError.new("Can't find test's working directory") if working_dir.nil?

    raise TestDirectoryError.new("Can't find test's relative path") if relative_file_path.nil?

   TestCase.new(
      working_dir: working_dir,
      file: relative_file_path,
      test_name: test_name,
      full_path: file_path,
    )
  end

  def test_name
    @test_name ||= line.strip.gsub(/def /, '').strip
  end

  def working_dir
    @working_dir ||=
      if file_path.match(/^(.*)test\//)
        file_path.match(/^(.*)test\//)[1]
      end
  end

  def relative_file_path
    @relative_file_path ||= file_path.gsub(/^#{working_dir}/, '')
  end

end
