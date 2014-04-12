require_relative 'repo'
require_relative 'test_grep_parser'

class InfoRepo < Repo
  def find_tests_by_name(regex)
    test_def_regex = "def .*#{regex}.*"
    results = grep(test_def_regex, file_pattern: '*_test.rb')

    tests = results.map do |result|
      TestGrepParser.parse(result)
    end.compact
  end

  private

  def grep(regex, file_pattern: '*')
    results = shell.run("git grep '#{regex}' -- '#{file_pattern}'").split("\n")
    results.map do |result|
      interpret_grep_result(result)
    end
  end

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
