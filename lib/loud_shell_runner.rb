require_relative 'shell_runner'

class LoudShellRunner < ShellRunner

  def run
    puts super
  end
end
