require "application_system_test_case"
require "colorize"

# @dev To save screenshot to tmp/capybara use save_screenshot
# @dev Run `rails db:test:purge` if testing with blob creation before test

class PaintingsTest < ApplicationSystemTestCase

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
  end

  test "visiting the index" do
    visit paintings_url
    assert_selector "h1", text: "My works"
    puts "\n2- Index route works \n".green
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
    accept_alert do
      click_on "Delete", match: :first
    end
    assert_text "Painting was successfully destroyed"
    puts "\n5- Able to destroy a painting \n".green
  end
end
