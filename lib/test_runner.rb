module TestRunner

  def self.run_method(test)
    command =  "cd #{test[:working_dir]} && ruby -I test #{test[:file]} --name=#{test[:test]}"

    puts command
    exec command
  end

  def self.run_file(test)
    command =  "cd #{test[:working_dir]} && ruby -I test #{test[:file]}"

    puts command
    exec command
  end

  def self.run_files(tests)
    command =  "cd #{tests[:working_dir]} && ruby -I test -e \"ARGV.each{|f| require Dir.pwd + '/' + f}\" #{tests[:files].inject('') {|s, t| s + ' ' + t }}"

    puts command
    exec command
  end

end
