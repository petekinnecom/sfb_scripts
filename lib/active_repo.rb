require_relative 'repo'

class ActiveRepo < Repo

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
end