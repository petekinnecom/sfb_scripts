class PrePushHook

  def self.check(command, env)
    new(command, env).check
  end

  attr_reader :shell, :repo, :push_command
  def initialize(command, env)
    @shell = env[:shell]
    @repo = env[:repo]
    @push_command = command
  end

  def check
    if affects_master? && is_destructive?
      shell.warn "[Policy] Don't force push or delete master.  (Denied by pre-push hook)"
      exit 1
    end
  end

  private

  def affects_master?
    push_command.match(/master/) || (repo.current_branch == 'master')
  end

  def is_destructive?
    push_command.match(/-f|delete|force| :master/)
  end

end
