class CreateEstablishmentSpecialties < ActiveRecord::Migration[8.0]
  def change
    create_table :establishment_specialties do |t|
      t.references :establishment, null: false, foreign_key: true
      t.references :specialty, null: false, foreign_key: true

      t.timestamps
    end
    
    # Add a unique index to prevent duplicate relationships
    add_index :establishment_specialties, [:establishment_id, :specialty_id], unique: true, name: 'idx_unique_establishment_specialty'
  end
end
