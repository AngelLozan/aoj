class CreatePaintings < ActiveRecord::Migration[7.0]
  def change
    create_table :paintings do |t|
      t.text :description
      t.integer :price
      t.string :title
      t.string :discount_code

      t.timestamps
    end
  end
end
