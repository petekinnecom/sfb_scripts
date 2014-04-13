require_relative 'repo'

class LazyRepo < Repo

  def files_changed
    all_files
  end

end
