require "codeclimate-test-reporter"
require "omniauth"
require "webmock/rspec"
require "sidekiq/testing"

RSpec.configure do |config|
  WebMock.disable_net_connect!
  config.include(WebMock::API)

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.after(:each) do
    Changeling.config.pardot = false
  end

  OmniAuth.config.test_mode = true

  mock_auth = OmniAuth::AuthHash.new(
    provider: "github",
    uid: "12345",
    credentials: {
      token: "abc123"
    },
    extra: {
      raw_info: {
        login: "joe"
      }
    }
  )
  OmniAuth.config.mock_auth[:github] = mock_auth

  ENV["FERNET_SECRET"] = "QiVChJj7VhO8bBsUrcYEvzi3pPOIYrCOPocE2Ebfzn4="

  CodeClimate::TestReporter.configure do |code_climate_config|
    code_climate_config.logger.level = Logger::WARN
  end
  CodeClimate::TestReporter.start

  config.before(:each) do
    stub_request(:post, "https://zipkin-staging.heroku.tools/api/v1/spans")
  end
end
