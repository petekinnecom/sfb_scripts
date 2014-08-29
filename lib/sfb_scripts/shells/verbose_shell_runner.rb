class VerboseShellRunner < LoudShellRunner

  def run(*args)
    super(*args).tap do |results|
      puts results
    end
  end
end
