require_relative 'test_runner'
require_relative 'test_collection'


class TestFileRunner

  def self.find(file, env)
    new(env).run(file)
  end

  def self.status(env)
    new(env).status
  end

  attr_reader :repo, :shell, :test_runner, :tests
  def initialize(env)
    @repo = env[:repo]
    @shell = env[:shell]
    @test_runner = env[:test_runner]
  end

  def find(file)
    files = repo.find_files(file).map {|f| {:file => f} }
    @tests = TestCollection.new(files)
    test_runner.run_files(tests)
  end

  def status
    files = repo.status_files.map {|f| {:file => f} }
    @tests = TestCollection.new(files)

    if tests.empty?
      shell.announce 'No tests in status'
      exit
    end

    if tests.include_selenium?
      handle_selenium
    end

    test_runner.run_files(tests)
  end

  private

  def handle_selenium
    if shell.deny?("The status includes some selenium files.  Do you wish to run those?")
      tests.remove_selenium!
    end
  end
end
