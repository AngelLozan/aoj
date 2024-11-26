class AddNoteToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :note, :string
  end
end
