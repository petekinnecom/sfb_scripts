class TestFinder

  def self.find(query, env)
    new(env, query).find
  end

  attr_accessor :shell, :repo, :query
  def initialize(env, query)
    @shell = env[:shell]
    @repo = env[:repo]
    @query = query
    @regex_searches = {}
  end

  def find
    return tests_found_by_name if tests_found_by_name.present?

    return tests_found_by_file_name if tests_found_by_file_name.present?

    return tests_found_by_full_regex if tests_found_by_full_regex.present?

    return TestCollection.new
  end

  private

  def tests_found_by_name
    @tests_found_by_name ||=
      begin
        tests_found_by_full_regex("^\s*def .*#{query}.*")
      end
  end

  def tests_found_by_full_regex(regex = query)
    @regex_searches[regex] ||=
      begin
        test_matches = []
        begin
          test_matches =  repo.grep(regex, file_pattern: '*_test.rb')
        rescue ShellRunner::CommandFailureError
          # git grep returns 1 if no results found
        end

        TestCollection.new(test_matches)
      end
  end

  def tests_found_by_file_name
    @tests_found_by_file_name ||=
      begin
        files = []
        files << repo.find_files(query).map {|f| {:file => f} }
        files.flatten!
        TestCollection.new(files)
      end
  end

  def might_be_method?(query)
    ! is_file_path?(query)
  end

  def is_file_path?(query)
    !! query.match(/\.rb/)
  end

end
