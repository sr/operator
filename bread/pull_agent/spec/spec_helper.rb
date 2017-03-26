ENV["CANOE_URL"] = "http://canoe.test"
ENV["CANOE_API_TOKEN"] = "faketoken"
ENV["ARTIFACTORY_USER"] = "fakeuser"
ENV["ARTIFACTORY_TOKEN"] = "faketoken"

$LOAD_PATH.unshift File.realpath(File.join(File.dirname(__FILE__), "..", "lib"))
require "pull_agent"
require "tmpdir"
require_relative "helpers/stdout"
require_relative "helpers/fixtures"

require "webmock/rspec"
WebMock.disable_net_connect!

require "simplecov"
SimpleCov.start

require "byebug"

RSpec.configure do |config|
  config.include TestHelpers::Stdout
  config.include TestHelpers::Fixtures

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true

    # Avoids false positives in expect { }.to_raise
    expectations.on_potential_false_positives = :raise
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
end
