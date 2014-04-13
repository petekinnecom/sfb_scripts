class TestCase
  attr_reader :working_dir, :file, :test_name, :full_path

  def initialize(working_dir: raise, file: raise, full_path: raise, test_name: '')
    @working_dir = working_dir
    @file = file
    @test_name = test_name
    @full_path = full_path
  end
end
