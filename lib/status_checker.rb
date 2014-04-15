class StatusChecker
  def self.report(env)
    new(env).report
  end

  attr_reader :repo, :shell, :untested_files
  def initialize(env)
    @repo = env[:repo]
    @shell = env[:shell]
    @untested_files = []
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
      exit 1
    end

  end

  private

  def test_files
    file_names.select {|f| f.match(/_test$/) }
  end

  def non_test_files
    file_names.reject {|f| f.match(/_test$/) }
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
end
