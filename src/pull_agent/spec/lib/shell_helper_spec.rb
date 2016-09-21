describe Pardot::PullAgent::ShellHelper do
  it "parse the right datacenter from hostname" do
    ENV["PULL_HOSTNAME"] = "pardot0-dbtools1-3-dfw"
    expect(Pardot::PullAgent::ShellHelper.datacenter).to eq("dfw")
  end

  after do
    ENV.delete("PULL_HOSTNAME")
  end
end
