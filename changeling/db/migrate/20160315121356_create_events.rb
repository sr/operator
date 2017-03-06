class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events, id: :uuid, primary_key: :uuid do |t|
      t.string :external_id
      t.string :app_name
      t.string :resource
      t.string :action
      t.jsonb :payload, null: false, default: {}

      t.timestamps null: false
    end
  end
end
