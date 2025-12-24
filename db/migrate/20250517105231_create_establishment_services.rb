class CreateEstablishmentServices < ActiveRecord::Migration[8.0]
  def change
    create_table :establishment_services do |t|
      t.references :establishment, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true

      t.timestamps
    end
    
    # Add a unique index to prevent duplicate relationships
    add_index :establishment_services, [:establishment_id, :service_id], unique: true, name: 'idx_unique_establishment_service'
  end
end
