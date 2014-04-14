require_relative 'test_runner'
require_relative 'test_collection'

class TestFileRunner

  def self.find(file, env)
    new(env).run(file)
  end

  def self.status(env)
    new(env).status
  end

  attr_reader :repo, :shell, :test_runner
  def initialize(env)
    @repo = env[:repo]
    @shell = env[:shell]
    @test_runner = env[:test_runner]
  end

  def find(file)
    files = repo.find_files(file).map {|f| {:file => f} }
    tests = TestCollection.new(files)
    test_runner.run_files(tests)
  end

  def status
    binding.pry
    repo.status_files
  end
end
