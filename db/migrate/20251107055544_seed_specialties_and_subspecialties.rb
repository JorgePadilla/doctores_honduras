class SeedSpecialtiesAndSubspecialties < ActiveRecord::Migration[8.0]
  def up
    # Load and run the seed files
    load Rails.root.join('db', 'seeds_specialties.rb')
    load Rails.root.join('db', 'seeds_subspecialties.rb')
  end

  def down
    # This migration only adds data, so we don't need to do anything on rollback
    # The data will remain in the database
  end
end
