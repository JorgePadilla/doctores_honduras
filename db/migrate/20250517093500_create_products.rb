class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :sku
      t.text :description
      t.decimal :price
      t.string :category
      t.string :image_url
      t.references :supplier, null: false, foreign_key: true

      t.timestamps
    end
  end
end
