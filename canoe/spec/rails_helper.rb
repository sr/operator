ENV["RAILS_ENV"] ||= "test"
ENV["GITHUB_USER"] = "nobody"
ENV["GITHUB_PASSWORD"] = ""
ENV["API_AUTH_TOKEN"] = "chatty_rulez_123"
require File.expand_path("../../config/environment", __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "spec_helper"
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!

Dir[Rails.root.join("spec/support/**/*.rb")].each do |f| require f end

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  # TODO: Extract TestHelpers into more cohesive modules
  config.include TestHelpers

  config.include FeatureHelpers, type: :feature
  config.include RequestHelpers, type: :request

  config.around type: :request do |example|
    OmniAuth.config.test_mode = true
    example.run
    OmniAuth.config.test_mode = false
  end
end
