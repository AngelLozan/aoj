# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# NOT WORKING WITH COMMAND RAKE TEST ATM
require_relative "config/application"
# require_relative "test/test_helper"
# require "rake/testtask"

Rails.application.load_tasks

desc "Look for style guide offenses in your code"
task :rubocop do
  sh "rubocop --format simple || true"
end

# Rake::TestTask.new(:test) do |t|
#   t.pattern = "test/**/*_test.rb"
# end

task default: :rubocop
# task default: %i[rubocop test:models test:system]
