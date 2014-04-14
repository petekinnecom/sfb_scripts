require_relative 'test_runner'
require_relative 'test_collection'


class TestFileRunner

  def self.find(file, env)
    new(env).run(file)
  end

  def self.status(env, ignore_selenium=false)
    new(env, ignore_selenium).status
  end

  attr_reader :repo, :shell, :test_runner, :tests, :ignore_selenium
  def initialize(env, ignore_selenium)
    @repo = env[:repo]
    @shell = env[:shell]
    @test_runner = env[:test_runner]
    @ignore_selenium = ignore_selenium
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
    if ignore_selenium || shell.deny?("The status includes some selenium files.  Do you wish to run those?")
      tests.remove_selenium!
    end
  end
end
