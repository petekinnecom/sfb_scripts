class StatusTestRunner

  def self.status(env, ignore_selenium=false)
    new(env, ignore_selenium).status
  end

  attr_reader :repo, :shell, :test_runner, :status_tests, :ignore_selenium
  def initialize(env, ignore_selenium)
    @repo = env[:repo]
    @shell = env[:shell]
    @test_runner = env[:test_runner]
    @ignore_selenium = ignore_selenium
    @status_tests = get_status_tests
  end

  def status
    if status_tests.include_selenium?
      handle_selenium
    end

    if status_tests.empty?
      shell.notify 'No tests to run'
      exit
    end

    test_runner.run_files(status_tests)
  end

  private

  def handle_selenium
    if ignore_selenium || shell.deny?("The status includes some selenium files.  Do you wish to run those?")
      status_tests.remove_selenium!
    end
  end

  def get_status_tests
    files = TestFilter.select_tests(repo.status_files)
    TestCollection.new(files)
  end
end
