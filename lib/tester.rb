require_relative 'needs_manager'
require_relative 'test_collection'
require_relative 'test_method_runner'
require_relative 'test_file_runner'

require 'rubygems'
require 'pry'

class Tester

  def self.needs
    [:shell, :repo, :test_runner]
  end

  def self.find(input, options)
    env = NeedsManager.configure(:test_runner, needs, options.merge(repo_type: :info))
    new(env).find(input)
  end

  def self.status(options)
    env = NeedsManager.configure(:test_runner, needs, options.merge(repo_type: :info))
    new(env).status(options)
  end

  attr_accessor :env
  def initialize(env)
    @env = env
  end

  def find(input)
    # each of these replaces this process if successful
    # so no need for logic control flow
    if ! input.match(/\.rb/)
      TestMethodRunner.run(input, env)
    end
    TestFileRunner.find(input, env)
  end

  def status(options)
    TestFileRunner.status(env, options[:no_selenium])
  end


end
