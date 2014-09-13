class StatusChecker
  def self.report(env, confirm_exit_status)
    new(env, confirm_exit_status).report
  end

  attr_reader :repo, :shell, :untested_files
  def initialize(env, confirm_exit_status)
    @repo = env[:repo]
    @shell = env[:shell]
    @untested_files = []
    @confirm_exit_status = confirm_exit_status
  end

  def report
    non_test_files.each do |file|
      if ! test_files.include? "#{file}_test"
        untested_files << full_path_by_basename(file)
      end
    end

    if untested_files.empty?
      shell.notify "All ruby files are tested!"
      exit 0
    else
      shell.warn "The following files have changed without being tested:\n\n#{untested_files.join("\n")}"

      STDIN.reopen('/dev/tty')
      if confirm_exit_status? && shell.confirm?("\nDo you still wish to commit?")
        exit 0
      else
        exit 1
      end
    end

  end

  private

  def test_files
    TestFilter.select_tests(file_names)
  end

  def non_test_files
    TestFilter.reject_tests(file_names)
  end

  def file_names
    @file_names ||= files.select {|f| f.match(/\.rb$/)}.map {|f| File.basename(f, '.rb') }
  end

  def files
    @files ||= repo.status_files
  end

  def full_path_by_basename(file)
    files.select {|f| File.basename(f, '.rb') == file }.first
  end

  def confirm_exit_status?
    @confirm_exit_status
  end
end
