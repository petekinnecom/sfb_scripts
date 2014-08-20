# this is a bummer...
require_relative 'monkey_patches/string_extension'
require_relative 'bundler/bundle_manager'
require_relative 'hooks/pre_push_hook'
require_relative 'migrations/migrator'
require_relative 'repositories/repo'
require_relative 'repositories/active_repo'
require_relative 'repositories/lazy_repo'
require_relative 'shells/shell_runner'
require_relative 'shells/loud_shell_runner'
require_relative 'test_running/status_checker'
require_relative 'test_running/test_case'
require_relative 'test_running/test_collection'
require_relative 'test_running/test_file_runner'
require_relative 'test_running/test_method_runner'
require_relative 'test_running/test_runner'


class NeedsManager

  def self.configure(task, needs, options)
    new(task, needs, options).configure
  end

  attr_reader :needs, :options, :env, :log_file
  def initialize(task, needs, options)
    @log_file = log_file_for(task)
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
    env[:shell] = shell_class.new(log_file, @working_directory)
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
    env[:migrator] = Migrator.new(shell: env[:shell], repo: env[:repo], migrate_engines: ! options[:no_engines])
  end

  def create_test_runner
    env[:test_runner] = TestRunner.new(
      shell: env[:shell],
      all_engines: options[:all_engines]
    )
  end

  def log_file_for(task)
    "/tmp/#{task}.log"
  end
end
