#!/usr/bin/env ruby

require 'pry'

def rebase_on_master
  rebase_origin_master
  perform_actions
end

def up_master
  move_to_master
  pull_origin_master
  perform_actions
end

def move_to_master
  run "git checkout master"
end

def reset_hard_origin_master
  run "git reset --hard origin/master"
end

def pull_origin_master
  git_up do
    fetch_origin
    reset_hard_origin_master
  end
end

def rebase_origin_master
  git_up do
    run "git pull --rebase origin master"
  end
end

def git_up
  @old_sha = get_current_sha
  yield
  @new_sha = get_current_sha
end

def get_current_sha
  run "git rev-parse HEAD"
end

def fetch_origin
  run 'git fetch origin'
end

def perform_actions
  if @old_sha == @new_sha
    puts 'No actions required'
  else
    bundle_where_necessary
    migrate_where_necessary
  end
end

def run(cmd, working_directory: repo_root)
  %x{ cd #{working_directory} && #{cmd} }
end

def repo_root
  @repo_root ||= %x[ git rev-parse --show-toplevel ].chomp
end

def bundle_where_necessary
  find("Gemfile.lock").each do |gemfile_lock|
    if has_changed?(gemfile_lock)
      bundle(directory_of(gemfile_lock))
    end
  end
end

def bundle(gemfile_directory)
  puts "bundle install --local in #{gemfile_directory}"
  puts (run "bundle install --local", working_directory: gemfile_directory)
  if $?.exitstatus != 0
    puts 'trying without --local'
    puts(run "bundle install", working_directory: gemfile_directory)
  end
end

def has_changed?(file_path)
  files.changed.include? file_path
end

def find(file_name)
  Dir.glob("**/#{file_name}")
end

def directory_of(file_path)
  File.dirname(file_path)
end

def migrate_where_necessary
  directories_to_migrate.each do |dir|
    puts "bundle exec rake db:migrate in #{dir}"
    run "bundle exec rake db:migrate", working_directory: dir
    run "RAILS_ENV=test bundle exec rake db:migrate", working_directory: dir
  end
end

def directories_to_migrate
  files_changed.select {|f| f.match("/migrate/") }.map {|f| File.dirname(f) }.uniq
end

def files_changed
  @files_changed ||= (run "git diff --name-only #{@old_sha}").split("\n")
end

Dir.chdir(repo_root)
up_master
