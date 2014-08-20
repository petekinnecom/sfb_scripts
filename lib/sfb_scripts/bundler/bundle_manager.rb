class BundleManager
  attr_accessor :shell, :repo, :queue

  def initialize(repo: raise, shell: raise, queue: raise)
    @shell = shell
    @repo = repo
    @queue = queue
  end

  def bundle_where_necessary
    shell.notify "\nBundling:"
    directories_to_bundle.each do |dir|
      queue.enqueue_b do
        bundle(dir)
      end
    end
    queue.join
  end

  private

  def bundle(gemfile_directory)
    begin
      shell.run "bundle install --local", dir: gemfile_directory
    rescue ShellRunner::CommandFailureError
      puts 'trying without --local'
      shell.run "bundle install", dir: gemfile_directory
    end
  end

  def directories_to_bundle
    changed_gemfile_locks.map do |gemfile_lock|
      directory_of(gemfile_lock)
    end
  end

  def changed_gemfile_locks
    all_gemfile_locks.select do |gemfile_lock|
      repo.changed?(gemfile_lock)
    end
  end

  def all_gemfile_locks
    find("Gemfile.lock")
  end

  def find(file_name)
    Dir.glob("**/#{file_name}")
  end

  def directory_of(file_path)
    File.dirname(file_path)
  end

end
