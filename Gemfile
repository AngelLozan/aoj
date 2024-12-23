source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.6"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.3.1"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem "devise"
gem "autoprefixer-rails"
gem "font-awesome-sass", "~> 6.1"
gem "simple_form", github: "heartcombo/simple_form"
gem 'kaminari'
gem 'bootstrap', '~> 5.2'
gem 'cloudinary'
gem "pg_search"
gem 'faker'
gem 'stripe'
# Security audits for dependencies and code.
gem 'bundler-audit', require: false
gem 'ruby_audit', require: false
gem "brakeman"
gem "sidekiq", "< 7"
gem "sidekiq-failures", "~> 1.0"
# Needed for paypal
gem 'gon', '~> 6.4'
gem 'figaro', '~> 1.2'
gem "braintree", "~> 4.14.0"
gem 'country_select', '~> 8.0', '>= 8.0.1'
gem "recaptcha"
gem 'mail'
gem 'json'
gem 'uri'
gem 'net-http'
gem 'nokogiri', '~> 1.12', '>= 1.12.4'
gem 'rubocop', require: false
gem 'ruby-lsp'
gem 'ruby-lsp-rails'
# gem 'capistrano', '~> 3.11'
# gem 'capistrano-rails', '~> 1.4'
# gem 'capistrano-passenger', '~> 0.2.0'
# gem 'capistrano-rbenv', '~> 2.1', '>= 2.1.4'
# gem 'ed25519', '>= 1.2', '< 2.0'
# gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
# gem 'net-smtp'


group :development, :test, :production do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "dotenv-rails"
  gem 'byebug', platform: :mri
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem 'letter_opener'
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "minitest-reporters"
  gem "colorize"
end
