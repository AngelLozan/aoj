require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "Validates address, phone and email" do
    ord = Order.new
    order = Order.new(address: "12345 kentucky", phone: "2536391485", email: "example@gmail.com")

    assert_not ord.save
    assert order.save
    puts "\n1- Only valid orders can be created \n".green
  end

  test "Set's default status to 'open' for all new orders" do
    order = Order.new(address: "12345 kentucky", phone: "2536391485", email: "example@gmail.com")
    assert_equal "open", order.status
    puts "\n\n2- Defaults to save all orders as 'open' on creation \n".green
  end
end
