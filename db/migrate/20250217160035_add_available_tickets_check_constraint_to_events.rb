class AddAvailableTicketsCheckConstraintToEvents < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :events, "available_tickets <= total_tickets", name: "available_tickets_check"
  end
end
