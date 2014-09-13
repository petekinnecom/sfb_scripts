class TestFilter
  def self.select_tests(files)
    filter(action: :select, files: files)
  end

  def self.reject_tests(files)
    filter(action: :reject, files: files)
  end

  private

  def self.filter(action:, files:)
    files.send(action) {|f| f.match(/_test(\.rb)?$/) }
  end
end
