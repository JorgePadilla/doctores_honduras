class MoveMaxConcurrentToDoctorBranches < ActiveRecord::Migration[8.0]
  def up
    add_column :doctor_branches, :max_concurrent, :integer, default: 1, null: false
    remove_column :doctor_agenda_settings, :max_concurrent
  end

  def down
    add_column :doctor_agenda_settings, :max_concurrent, :integer, default: 1, null: false
    remove_column :doctor_branches, :max_concurrent
  end
end
