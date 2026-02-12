class CreateBranchSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :branch_schedules do |t|
      t.references :doctor_branch, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :opens_at, null: false
      t.time :closes_at, null: false

      t.timestamps
    end

    add_index :branch_schedules, [:doctor_branch_id, :day_of_week], unique: true
  end
end
