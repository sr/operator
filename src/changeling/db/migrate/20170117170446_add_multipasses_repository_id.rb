class AddMultipassesRepositoryId < ActiveRecord::Migration[5.0]
  def change
    add_column :multipasses, :repository_id, :integer, null: true
    add_foreign_key :multipasses, :repositories

    Multipass.find_each do |multipass|
      owner = multipass.repository_name.split("/")[0]
      name = multipass.repository_name.split("/")[1]
      repository = GithubRepository.find_by!(owner: owner, name: name)

      multipass.update!(repository_id: repository.id)
    end
  end
end
