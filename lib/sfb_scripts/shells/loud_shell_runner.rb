class LoudShellRunner < ShellRunner

  def run(*args)
    super(*args).tap do |results|
      puts results
    end
  end
end