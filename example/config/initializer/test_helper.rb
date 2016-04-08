require 'grape'
require 'database_cleaner'
require 'rubygems'
require 'bundler'
require 'pry'

Bundler.setup :default, :test
require 'json'
require 'rack/test'
require 'capybara'
# require 'base64'
# require 'cookiejar'
require 'factory_girl'
require 'json'
# require 'mime/types'

I18n.enforce_available_locales = false

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

require File.expand_path '../../../application', __FILE__

DatabaseCleaner.strategy = :transaction
DC = DatabaseCleaner

RSpec.configure do |config|
  config.before(:each) do
    Garner.config.cache.clear
  end

  config.around(:each) do |spec|
    DC.cleaning do
        spec.run
    end
  end
end

require "airborne"
Airborne.configure do |config|
  config.rack_app = ApplicationServer
end

# require 'airborne'
