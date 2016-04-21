require "spec_helper"

describe Pardot::PullAgent::Environments::ProductionDfw do
  it "returns its name as production_dfw" do
    environment = Pardot::PullAgent::Environments.build(:production_dfw)
    expect(environment.name).to eq("production_dfw")
  end
end
