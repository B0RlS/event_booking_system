class AddIndexesToEventsAndTickets < ActiveRecord::Migration[7.1]
  def change
    add_index :events, :start_time
    add_index :events, :end_time
    add_index :events, :ticket_price_cents
    add_index :tickets, [:event_id, :state]
    add_index :tickets, :price_cents
  end
end
