class AddPaintingsToOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :paintings, :order, null: true, foreign_key: true
  end
end
