class Migrator
  attr_accessor :shell, :repo, :queue

  # hack: move engines flag into
  # another object that decides
  def initialize(repo: raise, shell: raise, queue: raise, migrate_engines: raise)
    @shell = shell
    @repo = repo
    @migrate_engines = migrate_engines
    @queue = queue
  end

  def migrate_where_necessary
    shell.notify "\nMigrating:"
    migrations.each do |migration|
      queue.enqueue_b do
        shell.run "RAILS_ENV=#{migration[:env]} bundle exec rake db:migrate", dir: migration[:dir]
      end
    end
    queue.join
  end

  def directories_to_migrate
    migrate_dirs = repo.files_changed.select {|f| f.match("/migrate/") }.map {|f| File.dirname(f) }.map {|dir| dir.gsub(/\/db\/migrate$/, '')}.uniq
    migrate_dirs.select {|d| in_rack_application?(d) };
  end

  private

  def migrations
    directories_to_migrate.map do |dir|
      [
        {env: "development",dir: dir},
        {env: "test", dir: dir}
      ]
    end.flatten
  end

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
