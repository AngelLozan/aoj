require "faker"

puts "cleaning database..."

Painting.destroy_all
User.destroy_all

puts "creating artist user"
email = ENV['EMAIL']
password = ENV['TEST_PASSWORD']

User.create!(email: email, password: password, password_confirmation: ENV["TEST_PASSWORD"], admin: true)

puts "created the artist successfully"

puts "Now creating some paintings"

paintings = []
paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }

paintings.each do |attributes|
  painting = Painting.create!(attributes)

  3.times do |i|
    file_path = Rails.root.join("app", "assets", "images", "photo#{i + 1}.jpeg")
    file = File.open(file_path)
    painting.photos.attach(io: file, filename: "photo#{i + 1}.jpeg", content_type: "image/jpeg")
    file.close
  end

  puts "Created #{painting.title}"
end

puts "Finished."
