require_relative 'needs_manager'
require_relative 'test_collection'
require_relative 'test_method_runner'
require_relative 'test_file_runner'
require_relative 'status_checker'

require 'rubygems'
require 'pry'

class Tester

  def self.needs
    [:shell, :repo, :test_runner]
  end

  def self.find(inputs, options)
    env = NeedsManager.configure(:test_runner, needs, options.merge(repo_type: :info))
    new(env).find(inputs)
  end

  def self.status(options)
    env = NeedsManager.configure(:test_runner, needs, options.merge(repo_type: :info))
    new(env).status(options)
  end

  def self.status_check(options)
    env = NeedsManager.configure(:test_runner, (needs - [:test_runner]), options.merge(repo_type: :info))
    new(env).status_check
  end

  attr_accessor :env
  def initialize(env)
    @env = env
  end

  def find(inputs)
    # each of these replaces this process if successful
    # so no need for logic control flow
    if query_might_be_method?(inputs)
      TestMethodRunner.run(inputs.first, env)
    end
    TestFileRunner.find(inputs, env)
    env[:shell].warn "Giving up :("
  end

  def status(options)
    TestFileRunner.status(env, options[:no_selenium])
  end

  def status_check
    StatusChecker.report(env)
  end

  private

  def query_might_be_method?(inputs)
    if inputs.any? {|input| is_file_path?(input) }
      false
    elsif inputs.size > 1
      false
    else
      true
    end
  end

  def is_file_path?(input)
    !! input.match(/\.rb/)
  end

end
