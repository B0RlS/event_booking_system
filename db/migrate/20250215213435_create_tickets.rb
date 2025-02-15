class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :price_cents, null: false
      t.string :currency, null: false
      t.string :state, null: false, default: 'pending'
      t.datetime :booked_at
      t.datetime :cancelled_at

      t.timestamps
    end

    add_index :tickets, :state
  end
end
