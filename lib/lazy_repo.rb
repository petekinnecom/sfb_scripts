require_relative 'repo'

class LazyRepo < Repo

  def files_changed
    all_files
  end

  private

  def all_files
    @all_files ||= shell.run("git ls-tree --full-tree -r HEAD --name-only").split("\n")
  end

end
