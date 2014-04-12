require_relative 'shell_runner'
require_relative 'loud_shell_runner'
require_relative 'repo'
require_relative 'lazy_repo'
require_relative 'migrator'
require_relative 'bundle_manager'
require 'rubygems'
require 'pry'

class Upper

  def self.up(function, loud_shell: false, lazy_repo: false )
    shell_class = loud_shell ? LoudShellRunner : ShellRunner
    repo_class = lazy_repo ? LazyRepo : Repo

    ShellRunner.reset_log
    new(Repo.root_dir, shell_class, repo_class).send(function)
  end

  attr_reader :shell, :repo, :bundler, :migrator

  def initialize(root_dir, shell_class, repo_class)
    Dir.chdir(root_dir)
    @shell = shell_class.new(root_dir)
    @repo = repo_class.new(shell: @shell)
    @bundler = BundleManager.new(shell: @shell, repo: @repo)
    @migrator = Migrator.new(shell: @shell, repo: @repo)
  end

  def up_master!
    repo.up_master!
    bundler.bundle_where_necessary
    migrator.migrate_where_necessary
  end

  def rebase_on_master!
    repo.rebase_on_master!
    bundler.bundle_where_necessary
    migrator.migrate_where_necessary
  end

  def no_git
    bundler.bundle_where_necessary
    migrator.migrate_where_necessary
  end
end
