class AddDatacenterToServers < ActiveRecord::Migration[5.0]
  def change
    add_column :servers, :datacenter, :string

    Server.reset_column_information
    Server.find_each do |server|
      server.calculate_datacenter
      server.save!
    end

    change_column :servers, :datacenter, :string, null: false
  end
end
