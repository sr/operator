Fabricator(:multipass) do
  reference_url { "https://#{Changeling.config.github_hostname}/#{Faker::Lorem.word}/#{Faker::Lorem.word}/pull/#{Faker::Number.number(3)}" }
  callback_url { "https://#{Faker::Internet.domain_name}" }
  release_id { Faker::Number.hexadecimal(7) }
  requester { Faker::Internet.user_name }
  impact { %w{low medium high}.sample }
  impact_probability { %w{low medium high}.sample }
  change_type { %w{minor major}.sample }
  peer_reviewer { Faker::Internet.user_name }
  sre_approver { nil }
  testing { [true, false].sample }
  backout_plan { Faker::Lorem.paragraph }
  team { Faker::Team.creature }
end

Fabricator(:sre_approved_multipass, :from => :multipass) do
  sre_approver { Faker::Internet.user_name }
end

Fabricator(:complete_multipass, :from => :multipass) do
  impact { "low" }
  impact_probability { "low" }
  testing { true }
  change_type { "minor" }
  peer_reviewer { Faker::Internet.user_name }
  sre_approver { SREApprover.all.first.github_login }
end

Fabricator(:incomplete_multipass, :from => :multipass) do
  impact             { "high" }
  impact_probability { "high" }
  change_type        { "major" }
  peer_reviewer      { nil }
  sre_approver       { nil }
  reference_url      { nil }
  requester          { nil }
end

Fabricator(:unreviewed_multipass, :from => :multipass) do
  impact             { "high" }
  impact_probability { "high" }
  change_type        { "minor" }
  peer_reviewer      { nil }
  sre_approver       { nil }
  reference_url      { "https://#{Changeling.config.github_hostname}/heroku/changeling/pull/32" }
  requester          { Faker::Internet.user_name }
  testing            { true }
end
