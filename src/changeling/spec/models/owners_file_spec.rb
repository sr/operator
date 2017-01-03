require "rails_helper"

RSpec.describe OwnersFile do
  it "returns repository team and user owners" do
    owners = OwnersFile.new(<<-EOS)
@Pardot/bread
# boomtown
hello world
@Pardot/bread
garbage
srozet@salesforce.com
@simon-rozet
@simon-rozet
EOS

    expect(owners.users).to eq(["simon-rozet"])
    expect(owners.teams).to eq(["Pardot/bread"])
  end
end
