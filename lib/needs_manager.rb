require_relative 'shell_runner'
require_relative 'loud_shell_runner'
require_relative 'repo'
require_relative 'lazy_repo'
require_relative 'migrator'
require_relative 'bundle_manager'
require_relative 'needs_manager'

class NeedsManager

  def self.configure(needs, options)
    new(needs, options).configure
  end

  attr_reader :needs, :options, :data
  def initialize(needs, options)
    @needs = needs
    @options = options
    @data = {}
  end

  def configure
    set_working_directory

    create_shell if needs.include? :shell
    create_repo if needs.include? :repo
    create_bundler if needs.include? :bundler
    create_migrator if needs.include? :migrator

    return data
  end

  def set_working_directory
    @working_directory = Repo.root_dir
    Dir.chdir(@working_directory)
  end

  def create_shell
    ShellRunner.reset_log
    data[:shell] = shell_class.new(@working_directory)
  end

  def shell_class
    if options[:loud]
      LoudShellRunner
    else
      ShellRunner
    end
  end

  def create_repo
    data[:repo] = repo_class.new(shell: data[:shell])
  end

  def repo_class
    if options[:repo_type] == :info
      InfoRepo
    elsif options[:repo_type] == :lazy
      LazyRepo
    else
      Repo
    end
  end

  def create_bundler
    data[:bundler] = BundleManager.new(shell: data[:shell], repo: data[:repo])
  end

  def create_migrator
    data[:migrator] = Migrator.new(shell: data[:shell], repo: data[:repo])
  end
end
