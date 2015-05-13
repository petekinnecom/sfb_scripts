# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = "sfb_scripts"
  s.version           = "1.9.1"

  s.authors           = ["Pete Kinnecom"]
  s.description       = "Easily update your rails app and run tests from command line"
  s.email             = ["pete.kinnecom@gmail.com"]

  s.homepage          = "http://github.com/petekinnecom/sfb_scripts/"
  s.licenses          = ["MIT"]
  s.require_paths     = ["lib"]
  s.rubygems_version  = "1.8.24"
  s.summary           = "Easily update your rails app and run tests from command line"

  s.files             = []

  s.add_dependency("app_up", "1.0.2")
  s.add_dependency("test_launcher", "0.1.0")
end

