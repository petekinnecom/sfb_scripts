class BundleManager
  attr_accessor :shell, :repo

  def initialize(repo: raise, shell: raise)
    @shell = shell
    @repo = repo
  end

  def bundle_where_necessary
    shell.notify "\nBundling:"
    find("Gemfile.lock").each do |gemfile_lock|
      if repo.changed?(gemfile_lock)
        bundle(directory_of(gemfile_lock))
      end
    end
  end

  def bundle(gemfile_directory)
    begin
      shell.run "bundle install --local", dir: gemfile_directory
    rescue ShellRunner::CommandFailureError
      puts 'trying without --local'
      shell.run "bundle install", dir: gemfile_directory
    end
  end

  def find(file_name)
    Dir.glob("**/#{file_name}")
  end

  def directory_of(file_path)
    File.dirname(file_path)
  end

end
