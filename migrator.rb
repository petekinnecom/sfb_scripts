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
