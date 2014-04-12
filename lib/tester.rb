require_relative 'shell_runner'
require_relative 'loud_shell_runner'
require_relative 'info_repo'

require 'rubygems'
require 'pry'

class Tester

  def self.test(function)
    new.send(function)
  end

  attr_accessor :shell, :repo
  def initialize
    @shell = LoudShellRunner.new(Repo.root_dir)
    @repo = InfoRepo.new(shell: shell)
  end

  def test
    tests = repo.find_tests_by_name('lease_document')
    test = tests.first

    shell.run "ruby -I test #{test[:file]} --name=#{test[:test]}", dir: test[:working_dir]
  end
end
