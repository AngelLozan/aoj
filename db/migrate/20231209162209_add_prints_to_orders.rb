class AddPrintsToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :prints, :jsonb, array: true, default: []
  end
end
