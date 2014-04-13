module TestRunner


  def self.run_method(test)
    command =  "cd #{test.working_dir} && #{named_test_runner(test.working_dir)} #{test.relative_path} --name=#{test.test_name}"

    puts command
    exec command
  end

  def self.run_files(tests)
    command =  "cd #{tests.working_dir} && #{test_collection_runner(tests.working_dir)} #{tests.relative_paths.inject('') {|s, t| s + ' ' + t }}"

    puts command
    exec command
  end

  private

  def self.test_runner_type(working_dir)
    if %x{cd #{working_dir} && ls bin/}.split("\n").include? 'testunit'
      :spring
    else
      :ruby
    end
  end

  def self.named_test_runner(working_dir)
    if test_runner_type(working_dir) == :spring
      'bin/testunit'
    else
      "ruby -I test"
    end
  end

  def self.test_collection_runner(working_dir)
    if test_runner_type(working_dir) == :spring
      'bin/testunit'
    else
      "ruby -I test -e \"ARGV.each{|f| require Dir.pwd + '/' + f}\""
    end
  end

end
