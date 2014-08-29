class LoudShellRunner < ShellRunner

  def handle_output_for(cmd)
    puts cmd
    log(cmd)
  end
end
