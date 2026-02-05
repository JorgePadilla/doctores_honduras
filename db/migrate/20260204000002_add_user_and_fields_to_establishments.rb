class AddUserAndFieldsToEstablishments < ActiveRecord::Migration[8.0]
  def change
    add_reference :establishments, :user, null: true, foreign_key: true
    add_column :establishments, :department_id, :bigint
    add_column :establishments, :city_id, :bigint
    add_column :establishments, :description, :text
    add_column :establishments, :website, :string
    add_column :establishments, :email, :string
  end
end
