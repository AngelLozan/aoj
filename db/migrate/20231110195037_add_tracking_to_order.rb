class AddTrackingToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :tracking, :string
  end
end
