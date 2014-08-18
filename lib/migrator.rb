class Migrator
  attr_accessor :shell, :repo

  # hack: move engines flag into
  # another object that decides
  def initialize(repo: raise, shell: raise, migrate_engines: raise)
    @shell = shell
    @repo = repo
    @migrate_engines = migrate_engines
  end

  def migrate_where_necessary
    shell.notify "\nMigrating:"
    directories_to_migrate.each do |dir|
      shell.run "bundle exec rake db:migrate", dir: dir
      shell.run "RAILS_ENV=test bundle exec rake db:migrate", dir: dir
    end
  end

  def directories_to_migrate
    migrate_dirs = repo.files_changed.select {|f| f.match("/migrate/") }.map {|f| File.dirname(f) }.map {|dir| dir.gsub(/\/db\/migrate$/, '')}.uniq
    migrate_dirs.select {|d| in_rack_application?(d) };
  end

  private

  def in_rack_application?(migrate_dir)
    if migrate_engines?
      true
    else
      ! migrate_dir.match(/engines/)
    end
  end

  def migrate_engines?
    @migrate_engines
  end
end
