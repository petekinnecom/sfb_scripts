require_relative 'test_runner'
require_relative 'test_collection'

class TestFileRunner

  def self.run(file, shell, repo)
    new(file, shell, repo).run
  end

  attr_reader :file, :repo, :shell
  def initialize(file, shell, repo)
    @file = file
    @repo = repo
    @shell = shell
  end

  def run
    files = repo.find_files(file).map {|f| {:file => f} }
    tests = TestCollection.new(files)
    TestRunner.run_files(tests)
  end
end
