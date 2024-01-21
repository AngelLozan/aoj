class AddPaypalOrderIdToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :paypal_order_id, :string
  end
end
