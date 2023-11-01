require "test_helper"

class OrderMailerTest < ActionMailer::TestCase

  Blob = ActiveStorage::Blob.create!(
    id: 2,
    key: "v1698786960/development/dvi5xiwkmrnelcucmlgaa1jdz08r.jpg",
    filename: "photo1.jpeg",
    content_type: "image/jpeg",
    metadata: {"identified"=>true},
    service_name: "cloudinary",
    byte_size: 211886,
    checksum: "s/YJcLD/rLXyjMIA/23ayA==",
    created_at: 'Fri, 04 Aug 2023 15:47:12.996524000 UTC +00:00'
  )

  setup do
    sign_in users(:admin)
    puts "\n\nSigned in the artist."
    @painting = paintings(:one)

    ActiveStorage::Attachment.create!(
      name: "photos",
      record_type: "Painting",
      record_id: 2,
      blob_id: 2,
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

  test "order" do
    mail = OrderMailer.order(@order).deliver_now
    assert_equal "You have a new order on your site!", mail.subject
    assert_equal ["scottloz@protonmail.com"], mail.to
    assert_equal ["jsadravi@gmail.com"], mail.from
    assert_match "Hi", mail.body.encoded
    puts "\n1- Order mailer works \n".green
  end

  test "customer" do
    mail = OrderMailer.customer(@order).deliver_now
    assert_equal "Thank you for your order!", mail.subject
    assert_equal ["scottloz@protonmail.com"], mail.to
    assert_equal ["jsadravi@gmail.com"], mail.from
    assert_match "Hi", mail.body.encoded
    puts "\n2- Customer mailer works \n".green
  end

end
