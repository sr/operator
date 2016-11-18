Fabricator(:user) do
  github_uid { Faker::Number.number(7) }
  github_login { Faker::Internet.user_name }
  encrypted_github_token { Faker::Number.hexadecimal(40) }
  team { Faker::Team.creature }
end
