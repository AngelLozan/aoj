ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/reporters"
require "capybara" # For rakefile
# require 'webmock/minitest'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  include Devise::Test::IntegrationHelpers
  include Warden::Test::Helpers
  Warden.test_mode!

  def log_in(user)
    sign_in(user)
  end
end

Capybara.save_path = Rails.root.join("tmp/capybara")
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(:color => true), Minitest::Reporters::ProgressReporter.new(:color => true)]
