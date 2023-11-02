require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest

  Blob = ActiveStorage::Blob.create!(
    id: 3,
    key: "v1698786959/development/u0p3c55bhyjvwdse32516ckspan4.jpg",
    filename: "photo3.jpeg",
    content_type: "image/jpeg",
    metadata: {"identified"=>true},
    service_name: "cloudinary",
    byte_size: 211886,
    checksum: "yCH3dumtEPGteSqmJQaaow==",
    created_at: 'Fri, 04 Aug 2023 15:47:12.996524000 UTC +00:00'
  )

  setup do
    sign_in users(:admin)
    puts "\n\nSigned in the artist."
    @painting = paintings(:one)

    ActiveStorage::Attachment.create!(
      name: "photos",
      record_type: "Painting",
      record_id: 3,
      blob_id: 3,
      record: @painting,
      created_at:'Fri, 04 Aug 2023 15:47:13.003858000 UTC +00:00'
    )

    @painting.save!
    puts "Painting created with photo. \n \n"

    @order = orders(:one)
    @order.paintings << @painting
    @order.save!
    puts "Order created with painting. \n \n"

  end

  test "should get index" do
    get orders_url
    assert_response :success
    puts "\n1- Index route works \n".green
  end

  test "should get new" do
    get new_order_url
    assert_response :success
    puts "\n2- New route works \n".green
  end

  test "should create order" do
    assert_difference("Order.count") do
      post orders_url, params: { order: { address: @order.address, email: @order.email, name: @order.name, phone: @order.phone, status: @order.status } }
    end

    assert_redirected_to paintings_url
    puts "\n3- Able to create an order \n".green
  end

end
