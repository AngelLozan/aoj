require "application_system_test_case"
require "faker"

class PaintingsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
    puts "\n\nSigned in the artist!"
    @painting = paintings(:one)
    # @painting = Painting.create!(title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100_00).to_i)
    file_path = Rails.root.join("app", "assets", "images", "photo1.jpeg")
    file = File.open(file_path)
    @painting.photos.attach(io: file, filename: "photo1.jpeg", content_type: "image/jpeg")
    file.close
    puts "Painting created with photo! \n \n"
  end

  test "visiting the index" do
    visit paintings_url
    assert_selector "h1", text: "My works"
    puts "1- Index route works \n"
  end

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
    puts "2- Able to create a painting \n"
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
    puts "3- Able to update the painting"
  end

  test "should destroy Painting" do
    visit painting_url(@painting)
    click_on "Destroy this painting", match: :first

    assert_text "Painting was successfully destroyed"
    puts "\n4- Able to destroy a painting \n"
  end
end
