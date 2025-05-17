class CreateSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :address
      t.string :phone
      t.string :email
      t.text :description
      t.string :logo_url

      t.timestamps
    end
  end
end
