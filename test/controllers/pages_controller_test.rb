require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest


  test "should get about page" do
    get about_url
    assert_response :success
    puts "\n1- About route works \n".green
  end

  test "should get CV page" do
    get cv_url
    assert_response :success
    puts "\n2- CV route works \n".green
  end

  test "should get home" do
    get root_url
    assert_response :success
    puts "\n3- Home route works \n".green
  end

  # test "should show painting" do
  #   get painting_url(@painting)
  #   assert_response :success
  #   puts "\n4- Show route works \n".green
  # end

  # test "should get edit" do
  #   get edit_painting_url(@painting)
  #   assert_response :success
  #   puts "\n5- Edit route works \n".green
  # end

  # test "should update painting" do
  #   patch painting_url(@painting), params: { painting: { description: @painting.description, discount_code: @painting.discount_code, price: @painting.price, title: @painting.title } }
  #   assert_redirected_to painting_url(@painting)
  #   puts "\n6- Allows update to paintings \n".green
  # end

  # test "should destroy painting" do
  #   assert_difference("Painting.count", -1) do
  #     delete painting_url(@painting)
  #   end

  #   assert_redirected_to paintings_url
  #   puts "\n7- Can delete a painting \n".green
  # end


end
