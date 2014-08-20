Gem::Specification.new do |s|
  s.name = "sfb_scripts"
  s.version           = "0.1.8"

  s.authors           = ["Pete Kinnecom"]
  s.description       = "Easily update your rails app and run tests from command line"
  s.email             = ["pete.kinnecom@gmail.com"]

  s.homepage          = "http://github.com/petekinnecom/sfb_scripts/"
  s.licenses          = ["MIT"]
  s.require_paths     = ["lib"]
  s.rubygems_version  = "1.8.24"
  s.summary           = "Easily update your rails app and run tests from command line"

  s.files             = `git ls-files -- lib`.split("\n")

  s.executables       << 'test_runner'
  s.executables       << 'app_up'

  s.add_dependency('thor', ['>= 0.19', '< 1.0'])
  s.add_dependency('work_queue', ['>= 2.5.3', '< 3.0'])
end

