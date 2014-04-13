require_relative 'needs_manager'
require_relative 'test_grep_parser'
require_relative 'test_method_runner'

require 'rubygems'
require 'pry'

class Tester

  def self.needs
    [:shell, :repo]
  end

  def self.find(input, options)
    env = NeedsManager.configure(needs, options.merge(repo_type: :info))
    new(env).find(input)
  end

  attr_accessor :shell, :repo
  def initialize(env)
    @shell = env[:shell]
    @repo = env[:repo]
  end

  def find(input)
    # each of these replaces this process if successful
    # so no need for logic control flow
    TestMethodRunner.run(input, shell, repo)
    TestFileRunner.run(input, shell, repo)
  end


end
