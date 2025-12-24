class CreatePaymentHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount
      t.string :status
      t.string :payment_method
      t.text :description

      t.timestamps
    end
  end
end
