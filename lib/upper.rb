require_relative 'needs_manager'
require_relative 'hook_manager'

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

  def self.install_hook!(options)
    env = NeedsManager.configure(:up, needs, options.merge(repo_type: :lazy))
    new(env).install_hook!
  end

  attr_reader :env

  def initialize(env)
    @env = env
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

  def install_hook!
    HookManager.install!(env)
  end
end
