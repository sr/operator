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
@pardot/app-sec *.php
@pardot/dba my.cnf
EOS

    expect(owners.teams).to eq(["Pardot/bread"])
    expect(owners.globs).to eq(
      "*.php" => "pardot/app-sec",
      "my.cnf" => "pardot/dba"
    )
  end
end
