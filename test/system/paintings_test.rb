require "application_system_test_case"
require "colorize"

# @dev To save screenshot to tmp/capybara use save_screenshot

class PaintingsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
    puts "\n\nSigned in the artist."
    @painting = paintings(:one)
    file_path = Rails.root.join("app", "assets", "images", "photo1.jpeg")
    file = File.open(file_path)
    @painting.photos.attach(io: file, filename: "photo1.jpeg", content_type: "image/jpeg")
    file.close
    puts "Painting created with photo. \n \n"
  end

  # @dev Remove this for gha as cloudinary file upload fails this.
  # test "visiting the index" do
  #   visit paintings_url
  #   assert_selector "h1", text: "My works"
  #   puts "\n2- Index route works \n".green
  # end

  test "should create painting with whole dollars" do
    visit new_painting_url
    # click_on "New painting"
    fill_in "Description", with: @painting.description
    fill_in "Discount code", with: @painting.discount_code
    fill_in "Price", with: 150
    fill_in "Title", with: @painting.title
    click_on "Create Painting"

    assert_text "Painting was successfully created"
    click_on "Back"
    puts "\n3- Able to create a painting \n".green
  end

  test "should update Painting" do
    visit painting_url(@painting)
    click_on "Edit this painting", match: :first
    fill_in "Description", with: @painting.description
    fill_in "Discount code", with: @painting.discount_code
    fill_in "Price", with: @painting.price
    fill_in "Title", with: @painting.title
    click_on "Update Painting"

    assert_text "Painting was successfully updated"
    click_on "Back"
    puts "\n4- Able to update the painting".green
  end

  test "should destroy Painting" do
    visit painting_url(@painting)
    click_on "Destroy this painting", match: :first

    assert_text "Painting was successfully destroyed"
    puts "\n5- Able to destroy a painting \n".green
  end
end
