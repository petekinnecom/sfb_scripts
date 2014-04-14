require_relative 'shell_runner'
require_relative 'loud_shell_runner'
require_relative 'repo'
require_relative 'lazy_repo'
require_relative 'active_repo'
require_relative 'migrator'
require_relative 'bundle_manager'
require_relative 'needs_manager'
require_relative 'test_runner'

class NeedsManager

  def self.configure(task, needs, options)
    new(task, needs, options).configure
  end

  attr_reader :needs, :options, :env, :task
  def initialize(task, needs, options)
    @task = task
    @needs = needs
    @options = options
    @env = {}
  end

  def configure
    set_working_directory

    create_shell
    create_repo if needs.include? :repo
    create_bundler if needs.include? :bundler
    create_migrator if needs.include? :migrator
    create_test_runner if needs.include? :test_runner

    return env
  end

  def set_working_directory
    @working_directory = Repo.root_dir
    Dir.chdir(@working_directory)
  end

  def create_shell
    env[:shell] = shell_class.new(task, @working_directory)
  end

  def shell_class
    if options[:loud]
      LoudShellRunner
    else
      ShellRunner
    end
  end

  def create_repo
    env[:repo] = repo_class.new(shell: env[:shell])
  end

  def repo_class
    if options[:repo_type] == :active
      ActiveRepo
    elsif options[:repo_type] == :lazy
      LazyRepo
    else
      Repo
    end
  end

  def create_bundler
    env[:bundler] = BundleManager.new(shell: env[:shell], repo: env[:repo])
  end

  def create_migrator
    env[:migrator] = Migrator.new(shell: env[:shell], repo: env[:repo])
  end

  def create_test_runner
    env[:test_runner] = TestRunner.new(
      shell: env[:shell],
      all_engines: options[:all_engines]
    )
  end
end
