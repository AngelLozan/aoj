class AddStatusToPaintings < ActiveRecord::Migration[7.0]
  def change
    add_column :paintings, :status, :integer, default: 0
  end
end
