require "spec_helper"

describe String do
  it "expects snakecase" do
    expect("ProductionDfw".underscore).to eq("production_dfw")
  end

  it "expects snakecase to be same for single word" do
    expect("Production".underscore).to eq("production")
  end

  it "expects snakecase multiple caps" do
    expect("ProductionDFW".underscore).to eq("production_dfw")
  end
end
