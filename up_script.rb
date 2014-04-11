#!/usr/bin/env ruby

class Shell
  CommandFailureError = Class.new(StandardError)

  attr_accessor :working_directory

  def initialize(working_directory)
    @working_directory = working_directory
  end

  def run(cmd, dir: working_directory)
    command = "cd #{dir} && #{cmd}"
    %x{ #{command} }.tap do
      raise CommandFailureError, "The following command has failed: #{command}" if ($?.exitstatus != 0)
    end
  end

  def stream(*args)
    puts run(*args)
  end
end

class Repo

  attr_reader :shell

  def initialize(shell: shell)
    @shell = shell
  end

  def rebase_on_master!
    rebase_origin_master
  end

  def up_master!
    move_to_master!
    pull_origin_master!
  end

  def files_changed
    @files_changed ||= (shell.run "git diff --name-only #{@old_sha}").split("\n")
  end

  def changed?(file_path)
    files_changed.include? file_path
  end

  private

  def up
    @old_sha = current_sha
    yield
    @new_sha = current_sha
  end

  def pull_origin_master!
    up do
      fetch_origin
      reset_hard_origin_master!
    end
  end

  def rebase_origin_master!
    up do
      shell.run "git pull --rebase origin master"
    end
  end

  def fetch_origin
    shell.run 'git fetch origin'
  end

  def reset_hard_origin_master!
    shell.run "git reset --hard origin/master"
  end

  def move_to_master!
    shell.run "git checkout master"
  end

  def current_sha
    shell.run "git rev-parse HEAD"
  end

end

class BundleManager
  attr_accessor :shell, :repo

  def initialize(repo: raise, shell: raise)
    @shell = shell
    @repo = repo
  end

  def bundle_where_necessary
    find("Gemfile.lock").each do |gemfile_lock|
      if repo.changed?(gemfile_lock)
        bundle(directory_of(gemfile_lock))
      end
    end
  end

  def bundle(gemfile_directory)
    puts "bundle install --local in #{gemfile_directory}"
    begin
      shell.stream "bundle install --local", dir: gemfile_directory
    rescue Shell::CommandFailureError
      puts 'trying without --local'
      shell.stream "bundle install", dir: gemfile_directory
    end
  end

  def find(file_name)
    Dir.glob("**/#{file_name}")
  end

  def directory_of(file_path)
    File.dirname(file_path)
  end

end

class Migrator
  attr_accessor :shell, :repo

  def initialize(repo: raise, shell: raise)
    @shell = shell
    @repo = repo
  end

  def migrate_where_necessary
    directories_to_migrate.each do |dir|
      puts "bundle exec rake db:migrate in #{dir}"
      shell.stream "bundle exec rake db:migrate", dir: dir
      shell.run "RAILS_ENV=test bundle exec rake db:migrate", dir: dir
    end
  end

  def directories_to_migrate
    repo.files_changed.select {|f| f.match("/migrate/") }.map {|f| File.dirname(f) }.uniq
  end

end

class Upper
  attr_reader :shell, :repo, :bundler, :migrator

  def initialize(root_dir)
    Dir.chdir(root_dir)
    @shell = Shell.new(root_dir)
    @repo = Repo.new(shell: @shell)
    @bundler = BundleManager.new(shell: @shell, repo: @repo)
    @migrator = Migrator.new(shell: @shell, repo: @repo)
  end

  def up_master
    repo.up_master!
    bundler.bundle_where_necessary
    migrator.migrate_where_necessary
  end
end

def root_dir
  @root_dir ||= %x[ git rev-parse --show-toplevel ].chomp
end

Upper.new(root_dir).up_master
