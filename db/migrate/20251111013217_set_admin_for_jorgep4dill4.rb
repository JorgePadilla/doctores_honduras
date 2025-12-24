class SetAdminForJorgep4dill4 < ActiveRecord::Migration[8.0]
  def up
    # Set admin=true for user jorgep4dill4@gmail.com
    User.where(email: 'jorgep4dill4@gmail.com').update_all(admin: true)
  end

  def down
    # Revert admin=false for user jorgep4dill4@gmail.com
    User.where(email: 'jorgep4dill4@gmail.com').update_all(admin: false)
  end
end
