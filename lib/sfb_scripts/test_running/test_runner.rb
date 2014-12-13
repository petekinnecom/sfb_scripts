class TestRunner

  attr_reader :shell, :all_engines_param, :always_ask_before_grouping_tests
  def initialize(env)
    @shell = env[:shell]
    @all_engines_param = env[:all_engines]
    @always_ask_before_grouping_tests = env[:always_ask_before_grouping_tests]
  end

  # Hack: this could use *a lot* of love
  # this could use some love
  def run(tests)

    if tests.empty?
      shell.warn "Unable to identify any tests."
      exit

    elsif tests.is_one_test_method?
      test = tests.first
      run_method(path: test.relative_path, name: test.test_name, dir: test.working_dir)
    elsif always_ask_before_grouping_tests
      ask_user_which_tests_to_run(tests)
    elsif tests.in_one_file? && tests.all? {|t| t.is_method? }
      shell.notify "Multiple matches in same file. Running those tests"
      test = tests.first
      run_method(path: test.relative_path, name: tests.query, dir: test.working_dir)

    elsif tests.in_one_file? #catches regex that matched a test file or other regex that matched in the body
      shell.notify "Matched one file. Running that file."
      run_files(tests)

    elsif tests.in_one_engine? && tests.full_paths.size < 4 # hack: maybe should ask here?
      shell.notify "Multiple matches across files in same engine. Running those files."
      run_files(tests)

    else
      ask_user_which_tests_to_run(tests)
    end
  end

  def run_method(path:, name:, dir:)
    test_runner = named_test_runner(dir)
    shell.exec("#{test_runner} #{path} --name=/#{name}/", dir: dir)
  end

  def ask_user_which_tests_to_run(tests)
      shell.warn 'Found too many tests. Please choose which matches you would like to run:'

      tests.uniq!.each_with_index do |t, index| 
        shell.notify "(#{index}) #{t.full_path}: #{t.test_name}" 
      end

      tests_to_run = shell.get_number_list_for_question('Please enter the match numbers you would like to run(comma seperated)')

      new_tests = tests_to_run.map do |index|
        tests[index]
      end
      @always_ask_before_grouping_tests = false
      run(TestCollection.new(new_tests))
  end

  def run_files(tests)
    begin
      test_runner = test_collection_runner(tests.working_dir)
      test_files = tests.relative_paths.join(' ')

      shell.exec("#{test_runner} #{test_files}", dir: tests.working_dir)
    rescue TestCollection::MultipleWorkingDirectoriesError => e
      if run_across_engines?
        run_across_engines(tests)
      end
    end
  end

  def run_across_engines(tests)
    shell.notify "\nfinding test runners"
    tests.working_dirs.each do |engine_dir|
      test_files = tests.relative_paths_in(engine_dir).join(' ')
      test_runner = test_collection_runner(engine_dir)

      shell.enqueue("#{test_runner} #{test_files}", dir: engine_dir)
    end
    shell.exec_queue
  end

  def test_runner_type(working_dir)
    if shell.run("ls bin", dir: working_dir).split("\n").include? 'testunit'
      :spring
    else
      :ruby
    end
  rescue ShellRunner::CommandFailureError
    :ruby
  end

  def named_test_runner(working_dir)
    if test_runner_type(working_dir) == :spring
      # hack:
      # Add some options for using spring.
      #
      #"bin/testunit"
      "ruby -I test"
    else
      "ruby -I test"
    end
  end

  def test_collection_runner(working_dir)
    if test_runner_type(working_dir) == :spring
      #"bin/testunit"
      %{ruby -I test -e 'ARGV.each { |file| require(Dir.pwd + "/" + file) }'}
    else
      %{ruby -I test -e 'ARGV.each { |file| require(Dir.pwd + "/" + file) }'}
    end
  end

  def run_across_engines?
    all_engines_param || shell.confirm?("Test files are in multiple engines.  Run them all?")
  end

end
