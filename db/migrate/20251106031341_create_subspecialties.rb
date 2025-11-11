class CreateSubspecialties < ActiveRecord::Migration[8.0]
  def change
    create_table :subspecialties do |t|
      t.string :name
      t.references :specialty, null: false, foreign_key: true

      t.timestamps
    end
  end
end
