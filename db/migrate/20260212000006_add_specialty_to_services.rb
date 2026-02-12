class AddSpecialtyToServices < ActiveRecord::Migration[8.0]
  def change
    add_reference :services, :specialty, foreign_key: true, null: true
  end
end
