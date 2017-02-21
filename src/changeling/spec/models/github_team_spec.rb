require "rails_helper"

describe GithubTeam do
  it "properly implements equality and hashing" do
    expect(GithubTeam.new("foo")).to eq(GithubTeam.new("foo"))
    expect(GithubTeam.new("foo")).to eql(GithubTeam.new("foo"))
    expect(GithubTeam.new("foo").hash).to eq(GithubTeam.new("foo").hash)

    expect(GithubTeam.new("foo")).to_not eq(GithubTeam.new("bar"))
    expect(GithubTeam.new("foo")).to_not eql(GithubTeam.new("bar"))
    expect(GithubTeam.new("foo").hash).to_not eq(GithubTeam.new("bar").hash)
  end
end
