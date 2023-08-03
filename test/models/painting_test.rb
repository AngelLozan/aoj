require "test_helper"
require "colorize"

class PaintingTest < ActiveSupport::TestCase
  test "Validates title, description and price" do
    painty = Painting.new
    painting = Painting.new(title: "test", description: "testing description", price: 10000)

    assert_not painty.save
    assert painting.save
    puts "\n1- Only valid paintings can be created \n".green
  end

  test "Set's default availability to 'available' for all new paintings" do
    painting = Painting.new(title: "test", description: "testing description", price: 100)
    assert_equal "available", painting.status
    puts "\n\n2- Defaults to save all paintings as 'available' on creation \n".green
  end
end

