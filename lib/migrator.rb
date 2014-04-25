class Migrator
  attr_accessor :shell, :repo

  def initialize(repo: raise, shell: raise)
    @shell = shell
    @repo = repo
  end

  def migrate_where_necessary
    directories_to_migrate.each do |dir|
      shell.run "bundle exec rake db:create db:migrate", dir: dir
      shell.run "RAILS_ENV=test bundle exec rake db:create db:migrate", dir: dir
    end
  end

  def directories_to_migrate
    migrate_dirs = repo.files_changed.select {|f| f.match("/migrate/") }.map {|f| File.dirname(f) }.uniq
    migrate_dirs.select {|d| in_rack_application?(d) };
  end

  private

  def in_rack_application?(migrate_dir)
    root_dir = migrate_dir.gsub(/db\/migrate$/, '')
    File.file?("#{root_dir}/config.ru")
  end

end
