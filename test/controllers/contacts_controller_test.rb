require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_contact_url
    assert_response :success
  end

  test "should create contact" do
    assert_difference("Contact.count") do
      post contacts_url, params: { contact: { email: "visitor@example.com", message: "Hello", name: "Visitor", subject: "Commission" } }
    end

    assert_redirected_to new_contact_url
  end
end
