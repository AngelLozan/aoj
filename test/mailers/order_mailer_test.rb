require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  test "order" do
    mail = OrderMailer.order
    assert_equal "Order", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
