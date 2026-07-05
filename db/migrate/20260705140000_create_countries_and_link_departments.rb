class CreateCountriesAndLinkDepartments < ActiveRecord::Migration[8.0]
  def up
    create_table :countries do |t|
      t.string :name, null: false
      t.string :iso_code

      t.timestamps
    end
    add_index :countries, :name, unique: true

    add_reference :departments, :country, foreign_key: true

    # Backfill: every existing department belongs to Honduras.
    countries = Class.new(ActiveRecord::Base) { self.table_name = "countries" }
    hn = countries.create!(name: "Honduras", iso_code: "HN")
    execute("UPDATE departments SET country_id = #{hn.id} WHERE country_id IS NULL")

    change_column_null :departments, :country_id, false
  end

  def down
    remove_reference :departments, :country, foreign_key: true
    drop_table :countries
  end
end
