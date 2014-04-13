require_relative 'repo'

class InfoRepo < Repo

  def grep(regex, file_pattern: '*')
    results = shell.run("git grep '#{regex}' -- '#{file_pattern}'").split("\n")
    results.map do |result|
      interpret_grep_result(result)
    end
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
end
