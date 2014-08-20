class LazyRepo < Repo

  def initialize(*args)
    super
    set_all_files
  end

  def files_changed
    @all_files
  end

  def set_all_files
    shell.notify "\nIdentifying all files:"
    @all_files = shell.run("git ls-tree --full-tree -r HEAD --name-only").split("\n")
  end
end
