class BundleManager
  attr_accessor :shell, :repo, :queue

  def initialize(repo: raise, shell: raise, queue: raise)
    @shell = shell
    @repo = repo
    @queue = queue
  end

  def bundle_where_necessary
    shell.notify "\nBundling:"
    find("Gemfile.lock").each do |gemfile_lock|
      if repo.changed?(gemfile_lock)
        queue.enqueue_b do
          bundle(directory_of(gemfile_lock))
        end
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
    find("Gemfile.lock")
      .select { |gemfile_lock|
        repo.changed?(gemfile_lock)
      }
      .map { |gemfile_lock| 
        directory_of(gemfile_lock)
      }
  end

  def find(file_name)
    Dir.glob("**/#{file_name}")
  end

  def directory_of(file_path)
    File.dirname(file_path)
  end

end
