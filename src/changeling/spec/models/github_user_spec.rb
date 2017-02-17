require "rails_helper"

describe GithubUser do
  it "properly implements equality and hashing" do
    expect(GithubUser.new("foo")).to eq(GithubUser.new("foo"))
    expect(GithubUser.new("foo")).to eql(GithubUser.new("foo"))
    expect(GithubUser.new("foo").hash).to eq(GithubUser.new("foo").hash)

    expect(GithubUser.new("foo")).to_not eq(GithubUser.new("bar"))
    expect(GithubUser.new("foo")).to_not eql(GithubUser.new("bar"))
    expect(GithubUser.new("foo").hash).to_not eq(GithubUser.new("bar").hash)
  end
end
