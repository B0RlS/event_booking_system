class RemoveQuantityFromTickets < ActiveRecord::Migration[7.1]
  def change
    remove_column :tickets, :quantity, :integer
  end
end
