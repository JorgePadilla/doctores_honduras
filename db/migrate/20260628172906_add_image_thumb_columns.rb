class AddImageThumbColumns < ActiveRecord::Migration[8.0]
  def change
    add_column :doctor_profiles, :image_thumb_url, :string
    add_column :establishments, :logo_thumb_url, :string
    add_column :establishments, :building_image_thumb_url, :string
    add_column :suppliers, :logo_thumb_url, :string
    add_column :products, :image_thumb_url, :string

    # News/Articles: table is an unused scaffold today. Add image columns now so the
    # upload pipeline is ready when the news feature is built (see plan §G).
    add_column :articles, :image_url, :string
    add_column :articles, :image_thumb_url, :string
  end
end
