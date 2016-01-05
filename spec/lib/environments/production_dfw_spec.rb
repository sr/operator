require "environments"

describe Environments::ProductionDfw do
  it "returns its name as production_dfw" do
    environment = Environments.build(:production_dfw)
    expect(environment.name).to eq("production_dfw")
  end
end
