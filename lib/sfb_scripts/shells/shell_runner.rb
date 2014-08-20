class ShellRunner
  CommandFailureError = Class.new(StandardError)

  attr_accessor :working_directory, :log_path

  def initialize(log_path, working_directory)
    @working_directory = working_directory
    @queue = ''
    @log_path = log_path
    reset_log
  end

  def run(cmd, dir: working_directory)
    command = "cd #{dir} && #{cmd}"
    puts command
    log command
    %x{ set -o pipefail && #{command} 2>> #{log_path} | tee -a #{log_path} }.chomp.tap do
      raise CommandFailureError, "The following command has failed: #{command}.  See #{log_path} for a full log." if ($?.exitstatus != 0)
    end
  end

  def exec(cmd, dir: working_directory)
    command = "cd #{dir} && #{cmd}"
    notify "\n#{command}"
    Kernel.exec command
  end

  def enqueue(cmd, dir: working_directory)
    command = "cd #{dir} && #{cmd} && cd -"
    @queue += "#{command};\n"
  end

  def confirm?(question)
    warn "#{question} [Yn]"
    answer = STDIN.gets.strip.downcase
    return answer != 'n'
  end

  def deny?(question)
    ! confirm?(question)
  end

  def exec_queue
    notify 'running: '
    notify ''
    notify @queue
    Kernel.exec @queue
  end

  def warn(msg)
    log msg
    puts msg.red
  end

  def notify(msg)
    log msg
    puts msg.yellow
  end

  def log(msg)
    %x{echo "#{msg}" >> #{log_path}}
  end

  def reset_log
    %x{echo "" > #{log_path}}
  end

end
