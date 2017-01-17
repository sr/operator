require "rails_helper"

RSpec.describe GithubInstallation do
  before(:each) do
    @github_install = GithubInstallation.current
  end

  def stub_organizations(organizations)
    orgs_data = []
    organizations.keys.each_with_index do |name, index|
      orgs_data << { id: index, login: name }
    end

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/user/orgs")
      .to_return(body: JSON.dump(orgs_data), headers: { "Content-Type" => "application/json" })

    orgs_data.each do |org|
      repos_data = []
      organizations.fetch(org.fetch(:login)).each_with_index do |name, index|
        repos_data << { id: index, name: name, owner: org }
      end

      stub_request(:get, "#{Changeling.config.github_api_endpoint}/orgs/#{org.fetch(:login)}/repos")
        .to_return(body: JSON.dump(repos_data), headers: { "Content-Type" => "application/json" })
    end
  end

  it "synchronizes repositories" do
    stub_organizations(heroku: ["changeling", "bread"])

    expect(@github_install.repositories.count).to eq(0)
    @github_install.synchronize
    expect(@github_install.repositories.count).to eq(2)

    repo_1 = @github_install.repositories[0]
    expect(repo_1.github_owner_id).to eq(0)
    expect(repo_1.github_id).to eq(0)
    expect(repo_1.owner).to eq("heroku")
    expect(repo_1.name).to eq("changeling")
    expect(repo_1.deleted_at).to eq(nil)

    repo_2 = @github_install.repositories[1]
    expect(repo_2.github_owner_id).to eq(0)
    expect(repo_2.github_id).to eq(1)
    expect(repo_2.owner).to eq("heroku")
    expect(repo_2.name).to eq("bread")
    expect(repo_2.deleted_at).to eq(nil)

    stub_organizations(heroku: ["changeling"])
    @github_install.synchronize
    @github_install.reload
    expect(@github_install.repositories[1].deleted_at).to_not eq(nil)
  end
end
