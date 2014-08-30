require_relative 'needs_manager'

class Upper

  def self.needs
    [:shell, :repo, :bundler, :migrator]
  end

  def self.with_defaults(options)
    {loud: true}.merge(options)
  end

  def self.arbitrary_action!(git_command, options)
    env = NeedsManager.configure(:up, needs, with_defaults(options).merge(repo_type: :active))
    new(env).arbitrary_action!(git_command)
  end

  def self.rebase_on_branch!(options)
    env = NeedsManager.configure(:up, needs, with_defaults(options).merge(repo_type: :active))
    new(env).arbitrary_action!("pull --rebase origin #{env[:repo].current_branch}")
  end

  def self.rebase_on_master!(options)
    env = NeedsManager.configure(:up, needs, with_defaults(options).merge(repo_type: :active))
    new(env).arbitrary_action!("pull --rebase origin master")
  end

  def self.up_master!(options)
    env = NeedsManager.configure(:up, needs, with_defaults(options).merge(repo_type: :active))
    new(env).up_master!
  end

  def self.no_git(options)
    env = NeedsManager.configure(:up, needs, with_defaults(options).merge(repo_type: :lazy))
    new(env).no_git
  end

  def self.finish_rebase(options)
    env = NeedsManager.configure(:up, needs, with_defaults(options).merge(repo_type: :active))
    new(env).finish_rebase
  end

  def self.install_hooks(options)
    env = NeedsManager.configure(:up, needs, with_defaults(options).merge(repo_type: :lazy))
    new(env).install_hooks
  end

  def self.pre_push_hook(git_command, options)
    env = NeedsManager.configure(:up, needs, with_defaults(options).merge(repo_type: :active))
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

  def arbitrary_action!(git_command)
    repo.alter!(git_command)
    bundler.bundle_where_necessary
    migrator.migrate_where_necessary
  end

  def no_git
    env[:shell].notify "\nBundling and migrating without checking diffs:"
    bundler.bundle_where_necessary
    migrator.migrate_where_necessary
  end

  def finish_rebase
    repo.compare_with_reflog
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
