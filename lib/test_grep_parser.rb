class TestGrepParser
  TestDirectoryError = Class.new(StandardError)

  def self.parse(grep_result)
    new(grep_result).parse
  end


  attr_reader :grep_result

  def initialize(grep_result)
    @grep_result = grep_result
  end

  def parse
    return nil unless test_name.match(/^test_/)

    raise TestDirectoryError.new("Can't find test's working directory") if working_dir.nil?

    raise TestDirectoryError.new("Can't find test's relative path") if relative_file_path.nil?

    {
      working_dir: working_dir,
      file: relative_file_path,
      test: test_name,
    }
  end

  def test_name
    @test_name ||= grep_result[:line].strip.gsub(/def /, '').strip
  end

  def working_dir
    @working_dir ||=
      if grep_result[:file].match(/^(.*)test\//)
        grep_result[:file].match(/^(.*)test\//)[1]
      end
  end

  def relative_file_path
    @relative_file_path ||= grep_result[:file].gsub(/^#{working_dir}/, '')
  end

end
