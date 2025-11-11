class SeedDepartmentsAndCities < ActiveRecord::Migration[8.0]
  def up
    load Rails.root.join('db', 'seeds_departments.rb')
    load Rails.root.join('db', 'seeds_cities.rb')
  end

  def down
    # This is a one-way migration for seeding
    raise ActiveRecord::IrreversibleMigration
  end
end
