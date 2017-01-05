require "rails_helper"

RSpec.describe RepositoryOwnersFile do
  it "synchronizes OWNERS files using the GitHub API" do
    repo_name = PardotRepository::CHEF

    owners = {
      type: "file",
      encoding: "base64",
      content: Base64.encode64("@Pardot/bread\n")
    }

    items = [
      {
        name: "OWNERS",
        path: "OWNERS"
      },
      {
        name: "owners_file_spec.rb",
        path: "src/changeling/spec/owners_file_spec.rb"
      }
    ]

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/repos/#{repo_name}/contents/OWNERS")
      .to_return(body: JSON.dump(owners), headers: { "Content-Type" => "application/json" })

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/search/code?q=in:path%20filename:OWNERS%20repo:#{repo_name}")
      .to_return(body: JSON.dump(items: items), headers: { "Content-Type" => "application/json" })

    expect(RepositoryOwnersFile.count).to eq(0)
    RepositoryOwnersFile.synchronize(repo_name)
    expect(RepositoryOwnersFile.count).to eq(1)

    owners_file = RepositoryOwnersFile.first!
    expect(owners_file.repository_name).to eq(repo_name)
    expect(owners_file.path_name).to eq("OWNERS")
    expect(owners_file.content).to eq("@Pardot/bread\n")
  end
end
