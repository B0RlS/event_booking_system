class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string   :name,                null: false
      t.text     :description,         null: false
      t.string   :location,            null: false
      t.datetime :start_time,          null: false
      t.datetime :end_time
      t.integer  :total_tickets,       null: false
      t.integer  :available_tickets,   null: false
      t.integer  :ticket_price_cents,  null: false
      t.string   :currency,            null: false
      t.float    :rate
      t.integer  :created_by,          null: false
      t.string   :state,               null: false, default: 'active'

      t.timestamps
    end

    add_index :events, :created_by
    add_index :events, :state
  end
end
