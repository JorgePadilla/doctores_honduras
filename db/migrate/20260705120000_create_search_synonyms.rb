class CreateSearchSynonyms < ActiveRecord::Migration[8.0]
  def change
    create_table :search_synonyms do |t|
      t.string :term, null: false
      t.text :keywords, null: false

      t.timestamps
    end

    add_index :search_synonyms, :term, unique: true
  end
end
