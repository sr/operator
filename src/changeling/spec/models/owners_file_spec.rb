require "rails_helper"

RSpec.describe OwnersFile do
  it "returns repository owners" do
    owners = OwnersFile.new(<<-EOS)
@Pardot/bread
# boomtown
hello world
@simon-rozet
@simon-rozet
EOS
  expect(owners.users).to eq([OwnersFile::User.new("simon-rozet")])
  end
end
