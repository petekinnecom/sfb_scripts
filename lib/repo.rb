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
      rescue ShellRunner::CommandFailureError
        puts "Unable to rebase.  Maybe you need to stash local changes, or there are rebase conflicts"
        puts `git status`
        exit
      end
    end
  end

  def up_master!
    move_to_master!
    rebase_on_master!
  end

  def files_changed
    @files_changed ||= (shell.run "git diff --name-only #{@old_sha}").split("\n")
  end

  def changed?(file_path)
    files_changed.include? file_path
  end

  def all_files
    @all_files ||= shell.run("git ls-tree --full-tree -r HEAD --name-only").split("\n")
  end

  def find_files(pattern)
    shell.run("git ls-files '*#{pattern}*'").split("\n")
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
