class Repo

  def self.root_dir
    @root_dir ||= %x[ git rev-parse --show-toplevel ].chomp
  end

  attr_reader :shell

  def initialize(shell: shell)
    @shell = shell
  end

  def rebase_on_master!
    up do
      # will raise an error with merge conflicts
      begin
        shell.run "git pull --rebase origin master"
      rescue Shell::CommandFailureError
        puts "There are rebase conflicts. :("
        exit
      end
    end
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
