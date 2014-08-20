class HookManager

  def self.install!(env)
    new(env).install!
  end

  attr_reader :shell, :repo

  def initialize(env)
    @shell = env[:shell]
    @repo = env[:repo]
  end

  def is_installed?
    File.file?('.git/hooks/pre-push')
  end

  def install!
    return if is_installed?

    create_file
    make_executable
  end

  private

  def create_file
    shell.run %{echo 'app_up pre_push_hook "$(ps -ocommand= -p $PPID)"' > .git/hooks/pre-push}
    shell.run %{echo 'test_runner status_check --confirm_exit_status' > .git/hooks/pre-commit}
  end

  def make_executable
    shell.run "chmod +x .git/hooks/pre-push"
    shell.run "chmod +x .git/hooks/pre-commit"
  end
end
