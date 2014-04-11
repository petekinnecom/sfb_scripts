class Shell
  CommandFailureError = Class.new(StandardError)

  attr_accessor :working_directory

  def initialize(working_directory)
    @working_directory = working_directory
  end

  def run(cmd, dir: working_directory)
    command = "cd #{dir} && #{cmd}"
    %x{ #{command} }.tap do
      raise CommandFailureError, "The following command has failed: #{command}" if ($?.exitstatus != 0)
    end
  end

  def stream(*args)
    puts run(*args)
  end
end
