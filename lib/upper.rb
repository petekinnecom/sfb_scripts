require_relative 'needs_manager'
require 'rubygems'
require 'pry'

class Upper

  def self.needs
    [:shell, :repo, :bundler, :migrator]
  end

  def self.rebase_on_master!(options)
    env = NeedsManager.configure(needs, options.merge(repo_type: :active))
    new(env).rebase_on_master!
  end

  def self.up_master!(options)
    env = NeedsManager.configure(needs, options.merge(repo_type: :active))
    new(env).up_master!
  end

  def self.no_git(options)
    env = NeedsManager.configure(needs, options.merge(repo_type: :lazy))
    new(env).no_git
  end

  attr_reader :shell, :repo, :bundler, :migrator

  def initialize(env)
    @shell = env[:shell]
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
end
