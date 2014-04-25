Gem::Specification.new do |s|
  s.name = "dev_scripts"
  s.version           = "0.1.0"

  s.authors           = ["Pete Kinnecom"]
  s.description       = "Scripts that help stuff and things"
  s.email             = ["pete.kinnecom@appfolio.com"]

  s.homepage          = "http://petekinnecom.net"
  s.licenses          = ["MIT"]
  s.require_paths     = ["lib"]
  s.rubygems_version  = "1.8.24"
  s.summary           = "Scripts that help stuff and things"

  s.files             = `git ls-files -- lib`.split("\n")

  s.executables       << 'test_runner'
  s.executables       << 'app_up'

  s.add_dependency('thor', ['>= 0.19', '< 1.0'])
end

