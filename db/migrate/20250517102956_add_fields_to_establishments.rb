class AddFieldsToEstablishments < ActiveRecord::Migration[8.0]
  def change
    add_column :establishments, :logo_url, :string unless column_exists?(:establishments, :logo_url)
    add_column :establishments, :map_link, :string unless column_exists?(:establishments, :map_link)
  end
end
