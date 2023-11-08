class AddColumnsToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :city, :string
    add_column :orders, :zip, :integer
    add_column :orders, :state, :string
    add_column :orders, :country, :string
  end
end
