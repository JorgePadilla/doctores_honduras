class AddUserAndFieldsToSuppliers < ActiveRecord::Migration[8.0]
  def change
    add_reference :suppliers, :user, null: true, foreign_key: true
    add_column :suppliers, :category, :string
    add_column :suppliers, :website, :string
    add_column :suppliers, :department_id, :bigint
    add_column :suppliers, :city_id, :bigint
    add_column :suppliers, :featured, :boolean, default: false
    add_column :suppliers, :hidden, :boolean, default: false
  end
end
