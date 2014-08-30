class ActiveRepo < Repo

  def alter!(git_command)
    shell.notify "\nUpdating repo state:"
    up do
      # will raise an error with merge conflicts
      begin
        shell.run "git #{git_command}"
      rescue ShellRunner::CommandFailureError
        puts "Unable to rebase.  Maybe you need to stash local changes, or there are rebase conflicts"
        exit
      end
    end
  end

  def up_master!
    move_to_master!
    rebase_on_master!
  end

  def up
    old_sha = current_sha
    yield

    set_files_changed(old_sha)
  end

  def set_files_changed(old_sha)
    shell.notify "\nIdentifying changed files:"
    @files_changed = (shell.run "git diff --name-only #{old_sha}").split("\n")
  end

  def files_changed
    @files_changed
  end

  def pull_origin_master!
    up do
      fetch_origin
      reset_hard_origin_master!
    end
  end

  def compare_with_reflog
    old_sha = shell.run "git rev-parse HEAD@{1}"
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
end
