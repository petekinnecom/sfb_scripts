class FolderGuard

  attr_reader :denied_matches
  def initialize(denied_matches)
    @denied_matches = denied_matches
  end

  def allowed?(folder)
    denied_matches.select { |d| folder.match(d) }.empty?
  end
end
