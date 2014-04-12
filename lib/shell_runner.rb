class ShellRunner
  CommandFailureError = Class.new(StandardError)

  LOG_PATH = '/tmp/up_log.txt'

  def self.reset_log
    %x{echo "" > #{LOG_PATH}}
  end

  attr_accessor :working_directory

  def initialize(working_directory)
    @working_directory = working_directory
  end

  def run(cmd, dir: working_directory)
    command = "cd #{dir} && #{cmd}"
    puts command
    %x{ set -o pipefail && #{command} 2>> #{LOG_PATH} | tee -a /tmp/up_log.txt }.chomp.tap do
      raise CommandFailureError, "The following command has failed: #{command}.  See /tmp/up_log.txt for a full log." if ($?.exitstatus != 0)
    end
  end

end
