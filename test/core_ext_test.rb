require_relative "test_helper"
require "core_ext/underscore_string"

describe String do
  it "expects snakecase" do
    assert_equal "production_dfw", "ProductionDfw".underscore
  end

  it "expects snakecase to be same for single word" do
    assert_equal "production", "Production".underscore
  end

  it "expects snakecase multiple caps" do
    assert_equal "production_dfw", "ProductionDFW".underscore
  end
end
