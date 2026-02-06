class CreateProfileViews < ActiveRecord::Migration[8.0]
  def change
    create_table :profile_views do |t|
      t.string :viewable_type, null: false
      t.bigint :viewable_id, null: false
      t.bigint :viewer_id
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :profile_views, [:viewable_type, :viewable_id]
    add_index :profile_views, [:viewable_type, :viewable_id, :created_at]
    add_index :profile_views, [:viewer_id]
    add_index :profile_views, [:ip_address, :viewable_type, :viewable_id, :created_at], name: "idx_profile_views_dedup"
  end
end
