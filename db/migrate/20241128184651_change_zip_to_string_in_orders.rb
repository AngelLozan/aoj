class ChangeZipToStringInOrders < ActiveRecord::Migration[7.0]
  def change
    change_column :orders, :zip, :string
  end
end
