class Repo

  def self.root_dir
    @root_dir ||= %x[ git rev-parse --show-toplevel ].chomp
  end

  attr_reader :shell

  def initialize(shell: shell)
    @shell = shell
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

  def status_files
    statii = shell.run("git status -s").split("\n")
    r = statii.map do |status|
      status.strip!
      if status[0] == 'D'
        nil
      else
        status[1..-1].strip
      end
    end.compact
  end

  def grep(regex, file_pattern: '*')
    results = shell.run("git grep '#{regex}' -- '#{file_pattern}'").split("\n")
    results.map do |result|
      interpret_grep_result(result)
    end
  end

  def current_branch
    shell.run 'git rev-parse --abbrev-ref HEAD'
  end

  private

  def interpret_grep_result(grep_result)
    splits = grep_result.split(/:/)
    file = splits.shift
    line = splits.join(':')

    {
      :file => file,
      :line => line,
    }
  end

  def current_sha
    shell.run "git rev-parse HEAD"
  end

end
