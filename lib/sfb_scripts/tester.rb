require_relative 'needs_manager'

class Tester

  def self.needs
    [:shell, :repo, :test_runner]
  end

  def self.find(inputs, options)
    env = NeedsManager.configure(:test_runner, needs, options.merge(repo_type: :info))
    new(env).find(inputs)
  end

  def self.status(options)
    env = NeedsManager.configure(:test_runner, needs, options.merge(repo_type: :info))
    new(env).status(options)
  end

  def self.status_check(options)
    env = NeedsManager.configure(:test_runner, (needs - [:test_runner]), options.merge(repo_type: :info))
    new(env).status_check(options)
  end

  attr_accessor :env
  def initialize(env)
    @env = env
  end

  def find(inputs)
    # each of these replaces this process if successful
    # so no need for logic control flow
    if query_might_be_method?(inputs)
      TestMethodRunner.run(inputs.first, env)
    end

    TestFileRunner.find(inputs, env)

    TestMethodRunner.run_file_with_match(inputs.first, env)

    env[:shell].warn "Giving up :("
  end

  def status(options)
    TestFileRunner.status(env, options[:no_selenium])
  end

  def status_check(options)
    StatusChecker.report(env, options[:confirm_exit_status])
  end

  private

  def query_might_be_method?(inputs)
    if inputs.any? {|input| is_file_path?(input) }
      false
    elsif inputs.size > 1
      false
    else
      true
    end
  end

  def is_file_path?(input)
    !! input.match(/\.rb/)
  end

end
