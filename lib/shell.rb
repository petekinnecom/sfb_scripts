class Shell
  CommandFailureError = Class.new(StandardError)

  attr_accessor :working_directory

  def initialize(working_directory)
    @working_directory = working_directory
  end

  def run(cmd, dir: working_directory)
    command = "cd #{dir} && #{cmd}"
    %x{ #{command} 2> /tmp/up_log.txt | tee /tmp/up_log.txt }.chomp.tap do
      raise CommandFailureError, "The following command has failed: #{command}.  See /tmp/up_log.txt for a full log." if ($?.exitstatus != 0)
    end
  end

end
