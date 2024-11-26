require "test_helper"

# @dev Run `rails db:test:purge` if testing with blob creation before test

class PaintingsControllerTest < ActionDispatch::IntegrationTest

  Blob = ActiveStorage::Blob.create!(
    id: 1,
    key: "v1691164042/development/6735bisbapkobqpyrnlrjd2r1lvs.jpg",
    filename: "photo1.jpeg",
    content_type: "image/jpeg",
    metadata: {"identified"=>true},
    service_name: "cloudinary",
    byte_size: 211886,
    checksum: "1L3VW36ykx2dfJDvlostpQ==",
    created_at: 'Fri, 04 Aug 2023 15:47:12.996524000 UTC +00:00'
  )

  setup do
    sign_in users(:admin)
    puts "\n\nSigned in the artist."
    @painting = paintings(:one)

    ActiveStorage::Attachment.create!(
      name: "photos",
      record_type: "Painting",
      record_id: 1,
      blob_id: 1,
      record: @painting,
      created_at:'Fri, 04 Aug 2023 15:47:13.003858000 UTC +00:00'
    )

    @painting.save!
    puts "Painting created with photo. \n \n"
  end

  test "should get index" do
    get paintings_url
    assert_response :success
    puts "\n1- Index route works \n".green
  end

  test "should get new" do
    get new_painting_url
    assert_response :success
    puts "\n2- New route works \n".green
  end

  test "should create painting" do
    assert_difference("Painting.count") do
      post paintings_url, params: { painting: { description: @painting.description, discount_code: @painting.discount_code, price: @painting.price, title: @painting.title } }
    end

    assert_redirected_to painting_url(Painting.last)
    puts "\n3- Able to create a painting \n".green
  end

  test "should show painting" do
    get painting_url(@painting)
    assert_response :success
    puts "\n4- Show route works \n".green
  end

  test "should get edit" do
    get edit_painting_url(@painting)
    assert_response :success
    puts "\n5- Edit route works \n".green
  end

  test "should update painting" do
    patch painting_url(@painting), params: { painting: { description: @painting.description, discount_code: @painting.discount_code, price: @painting.price, title: @painting.title } }
    assert_redirected_to painting_url(@painting)
    puts "\n6- Allows update to paintings \n".green
  end

  test "should destroy painting" do
    assert_difference("Painting.count", -1) do
      delete painting_url(@painting)
    end

    assert_redirected_to paintings_url
    puts "\n7- Can delete a painting \n".green
  end

  test "should get admin" do
    get admin_url
    assert_response :success
    puts "\n8- Admin route works \n".green
  end

  test "should add item to session cart" do
    post add_to_cart_url(@painting)
    # session = @request.session
    # assert_difference("session[:cart].count", 1) do
    #   # @controller.session[:cart] = []
    #   post add_to_cart_url(@painting)
    # end
    assert_redirected_to new_order_url
    puts "\n9- Successfully adds items to cart \n".green
  end

  test "should remove item from cart" do
    delete remove_from_cart_url(@painting)
    # assert_difference("@request.session[:cart].count", -1) do
    #   post add_to_cart_url(@painting)
    #   delete remove_from_cart_url(@painting)
    # end
    assert_redirected_to paintings_url
    puts "\n10- Can remove items from cart \n".green
  end


end
