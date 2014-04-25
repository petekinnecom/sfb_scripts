require_relative 'needs_manager'
require_relative 'hook_manager'
require_relative 'pre_push_hook'

require 'rubygems'
require 'pry'

class Upper

  def self.needs
    [:shell, :repo, :bundler, :migrator]
  end

  def self.rebase_on_master!(options)
    env = NeedsManager.configure(:up, needs, options.merge(repo_type: :active))
    new(env).rebase_on_master!
  end

  def self.up_master!(options)
    env = NeedsManager.configure(:up, needs, options.merge(repo_type: :active))
    new(env).up_master!
  end

  def self.no_git(options)
    env = NeedsManager.configure(:up, needs, options.merge(repo_type: :lazy))
    new(env).no_git
  end

  def self.install_hooks(options)
    env = NeedsManager.configure(:up, needs, options.merge(repo_type: :lazy))
    new(env).install_hooks
  end

  def self.pre_push_hook(git_command, options)
    env = NeedsManager.configure(:up, needs, options.merge(repo_type: :lazy))
    new(env).pre_push_hook(git_command)
  end

  attr_reader :env, :repo, :bundler, :migrator

  def initialize(env)
    @env = env
    @repo = env[:repo]
    @bundler = env[:bundler]
    @migrator = env[:migrator]
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

  def install_hooks
    HookManager.install!(env)
  end

  def pre_push_hook(git_command)
    PrePushHook.check(git_command, env)
  end
end
