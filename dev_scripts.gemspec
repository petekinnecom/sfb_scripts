Gem::Specification.new do |s|
  s.name = "dev_scripts"
  s.version           = "0.0.1"

  s.authors           = ["Pete Kinnecom"]
  s.description       = "Scripts that help stuff and things"
  s.email             = ["pete.kinnecom@appfolio.com"]

  s.homepage          = "http://zombo.com"
  s.licenses          = ["MIT"]
  s.require_paths     = ["lib"]
  s.rubygems_version  = "1.8.24"
  s.summary           = "Capybara Page Objects pattern"

  s.files             = `git ls-files -- lib`.split("\n")
  s.executables       << 'up'

  #s.add_dependency('capybara', ['>= 1.1', '< 2.3'])
end

