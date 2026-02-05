class AddActiveAndFeaturedToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :active, :boolean, default: true
    add_column :products, :featured, :boolean, default: false
  end
end
