require "rails_helper"

RSpec.describe RepositoryOwnersFile do
  it "synchronizes OWNERS files using the GitHub API" do
    repo_name = PardotRepository::CHEF
    org_name = repo_name.split("/")[0]

    repo = GithubInstallation.current.repositories.create!(
      github_id: 1,
      github_owner_id: 1,
      owner: org_name,
      name: repo_name.split("/")[1]
    )

    owners = {
      type: "file",
      encoding: "base64",
      content: Base64.encode64("@Pardot/bread\n")
    }

    items = [
      {
        name: "OWNERS",
        path: "/OWNERS"
      },
      {
        name: "OWNERS",
        path: "cookbooks/pardot_mysql/OWNERS"
      },
      {
        name: "owners_file_spec.rb",
        path: "src/changeling/spec/owners_file_spec.rb"
      }
    ]

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/search/code?q=user:#{org_name}%20changeling")
      .to_return(body: JSON.dump(owners), headers: { "Content-Type" => "application/json" })

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/repos/#{repo_name}/contents/OWNERS")
      .to_return(body: JSON.dump(owners), headers: { "Content-Type" => "application/json" })
    stub_request(:get, "#{Changeling.config.github_api_endpoint}/repos/#{repo_name}/contents/cookbooks/pardot_mysql/OWNERS")
      .to_return(body: JSON.dump(owners), headers: { "Content-Type" => "application/json" })

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/search/code?q=in:path%20filename:OWNERS%20repo:#{repo_name}")
      .to_return(body: JSON.dump(items: items), headers: { "Content-Type" => "application/json" })

    expect(RepositoryOwnersFile.count).to eq(0)
    RepositoryOwnersFile.synchronize(repo_name)
    expect(RepositoryOwnersFile.count).to eq(2)

    owners_files = RepositoryOwnersFile.all.order("LENGTH(path_name) ASC")
    owners_file = owners_files.first!
    expect(owners_file.repository_id).to eq(repo.id)
    expect(owners_file.path_name).to eq("/OWNERS")
    expect(owners_file.content).to eq("@Pardot/bread\n")

    expect(owners_files.pluck(:path_name)).to eq(["/OWNERS", "/cookbooks/pardot_mysql/OWNERS"])

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/search/code?q=in:path%20filename:OWNERS%20repo:#{repo_name}")
      .to_return(body: JSON.dump(items: []), headers: { "Content-Type" => "application/json" })
    RepositoryOwnersFile.synchronize(repo_name)
    expect(RepositoryOwnersFile.count).to eq(0)
  end
end
