class AddBuildingImageUrlToEstablishments < ActiveRecord::Migration[8.0]
  def change
    add_column :establishments, :building_image_url, :string
  end
end
