require "rails_helper"

RSpec.describe GithubRepository do
  let(:repository) do
    GithubInstallation.current.repositories.create!(
      github_id: 1,
      github_owner_id: 1,
      owner: "heroku",
      name: "changeling"
    )
  end

  it "synchronizes repository configuration file" do
    config = Bread::RepositoryConfig.new(
      required_testing_statuses: ["Initial Job", "Test Jobs"],
      high_risk_files: Bread::RepositoryWatchlist.new(
        team: "security",
        globs: ["/templates/default/etc/sudoers.erb"]
      )
    )

    config_file = {
      type: "file",
      encoding: "base64",
      content: Base64.encode64(config.to_json)
    }

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/search/code?q=user:#{repository.owner}%20changeling")
      .to_return(body: JSON.dump(total_count: 0), headers: { "Content-Type" => "application/json" })
    stub_request(:get, "#{Changeling.config.github_api_endpoint}/repos/#{repository.full_name}/contents/#{GithubRepository::CONFIG_FILENAME}")
      .to_return(body: JSON.dump(config_file), headers: { "Content-Type" => "application/json" })

    expect(repository.config.required_testing_statuses).to eq(["Test Jobs"])
    expect(repository.config.watchlists).to eq([])
    expect(repository.config.high_risk_files).to eq([])

    repository.synchronize

    expect(repository.config.required_testing_statuses).to eq(["Initial Job", "Test Jobs"])
    expect(repository.config.high_risk_files[0].team).to eq("security")
    expect(repository.config.high_risk_files[0].globs.to_a).to eq(["/templates/default/etc/sudoers.erb"])
    expect(repository.config.watchlists).to eq([])

    config_file[:content] = Base64.encode64(JSON.dump(garbage: true))
    stub_request(:get, "#{Changeling.config.github_api_endpoint}/repos/#{repository.full_name}/contents/#{GithubRepository::CONFIG_FILENAME}")
      .to_return(body: JSON.dump(config_file), headers: { "Content-Type" => "application/json" })

    repository.synchronize
    expect(repository.config.required_testing_statuses).to eq(["Initial Job", "Test Jobs"])
  end

  it "synchronizes OWNERS files using the GitHub API" do
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

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/search/code?q=user:#{repository.owner}%20changeling")
      .to_return(body: JSON.dump(total_count: 5, items: items), headers: { "Content-Type" => "application/json" })

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/search/code?q=in:path%20filename:OWNERS%20repo:#{repository.full_name}")
      .to_return(body: JSON.dump(items: items), headers: { "Content-Type" => "application/json" })
    stub_request(:get, "#{Changeling.config.github_api_endpoint}/repos/#{repository.full_name}/contents/OWNERS")
      .to_return(body: JSON.dump(owners), headers: { "Content-Type" => "application/json" })
    stub_request(:get, "#{Changeling.config.github_api_endpoint}/repos/#{repository.full_name}/contents/cookbooks/pardot_mysql/OWNERS")
      .to_return(body: JSON.dump(owners), headers: { "Content-Type" => "application/json" })

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/repos/#{repository.full_name}/contents/#{GithubRepository::CONFIG_FILENAME}")
      .to_return(status: 404)

    expect(RepositoryOwnersFile.count).to eq(0)
    repository.synchronize
    expect(RepositoryOwnersFile.count).to eq(2)

    owners_files = RepositoryOwnersFile.all.order("LENGTH(path_name) ASC")
    owners_file = owners_files.first!
    expect(owners_file.repository_id).to eq(repository.id)
    expect(owners_file.path_name).to eq("/OWNERS")
    expect(owners_file.content).to eq("@Pardot/bread\n")

    expect(owners_files.pluck(:path_name)).to eq(["/OWNERS", "/cookbooks/pardot_mysql/OWNERS"])

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/search/code?q=in:path%20filename:OWNERS%20repo:#{repository.full_name}")
      .to_return(body: JSON.dump(items: []), headers: { "Content-Type" => "application/json" })
    repository.synchronize
    expect(RepositoryOwnersFile.count).to eq(0)
  end
end
