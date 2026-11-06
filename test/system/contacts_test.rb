require "application_system_test_case"

class ContactsTest < ApplicationSystemTestCase
  test "visiting the contact page" do
    visit new_contact_url
    assert_selector "h2", text: "Contact Me"
  end

  test "should create contact" do
    visit new_contact_url

    fill_in "Name", with: "Visitor"
    fill_in "Email", with: "visitor@example.com"
    fill_in "Subject", with: "Commission"
    fill_in "Message", with: "Hello"
    click_on "Submit"

    assert_text "Thank you for contacting me"
  end
end
