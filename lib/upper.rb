require_relative 'shell'
require_relative 'repo'
require_relative 'migrator'
require_relative 'bundle_manager'

class Upper

  def self.up_master
    Dir.chdir(Repo.root_dir)
    new(Repo.root_dir).up_master
  end

  attr_reader :shell, :repo, :bundler, :migrator

  def initialize(root_dir)
    @shell = Shell.new(root_dir)
    @repo = Repo.new(shell: @shell)
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
end
