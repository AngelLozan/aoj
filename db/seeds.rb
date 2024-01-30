require "faker"

puts "cleaning database..."

Painting.destroy_all
User.destroy_all
Order.destroy_all

puts "creating artist user"
email = ENV['EMAIL']
password = ENV['TEST_PASSWORD']

User.create!(email: email, password: password, password_confirmation: ENV["TEST_PASSWORD"], admin: true)

puts "created the artist successfully"

# @dev Create paintings during development for test. Uncomment:

puts "Now creating some paintings"

let_the_church_say = Painting.create!({ title: "Let the church say", description: "Original painting by Jaleh Sadravi", price: 120000 })
  file_path_1 = Rails.root.join("app", "assets", "images", "let_the_church_say.jpeg")
  file_1 = File.open(file_path_1)
  let_the_church_say.photos.attach(io: file_1, filename: "let_the_church_say.jpeg", content_type: "image/jpeg")
  file_1.close
four_generations = Painting.create!({ title: "Four generations", price: 120000, description:
  """
  Original painting by Jaleh Sadravi

  Acrylic on canvas

  16inches x 24 inches

  40x60 cm/s

  'Four Generations' is a piece that encapsulates the rich tapestry of familial bonds and the passage of time. Through the artful interplay of colors and carefully crafted details, the painting tells the story of four generations woven together by shared experiences, wisdom, and love. Each figure represents a distinct chapter in the family's legacy, creating a visual narrative that spans across time. The layers of history and connection depicted in 'Four Generations' celebrate the enduring strength of family ties, capturing the essence of heritage and the beauty found in the continuum of generations.
  """
 })
  file_path_2 = Rails.root.join("app", "assets", "images", "four_generations.jpeg")
  file_2 = File.open(file_path_2)
  four_generations.photos.attach(io: file_2, filename: "four_generations.jpeg", content_type: "image/jpeg")
  file_2.close
kindred_souls = Painting.create!({ title: "Kindred souls", price: 62500, description:
 """
  Original painting by Jaleh Sadravi

  8x12 inches

  acrylic on canvas
 """
})
  file_path_3 = Rails.root.join("app", "assets", "images", "kindred_souls.jpeg")
  file_3 = File.open(file_path_3)
  kindred_souls.photos.attach(io: file_3, filename: "kindred_souls.jpeg", content_type: "image/jpeg")
  file_3.close
community_of_faith = Painting.create!({ title: "Community of faith", price: 142500, description:
  """
  Original painting by Jaleh Sadravi

  acrylic on canvas, 27.5 inches by 19.5 inches
  """
})
  file_path_4 = Rails.root.join("app", "assets", "images", "community_of_faith.jpeg")
  file_4 = File.open(file_path_4)
  community_of_faith.photos.attach(io: file_4, filename: "community_of_faith.jpeg", content_type: "image/jpeg")
  file_4.close
free_to_shine = Painting.create!({ title: "Free to shine", price: 62500, description:
  """
  Original painting by Jaleh Sadravi
  


# paintings = []
# paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
# paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
# paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
# paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
# paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
# paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
# paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
# paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
# paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
# paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }
# paintings << { title: Faker::Commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100000) }

# paintings.each do |attributes|
#   painting = Painting.create!(attributes)

#   3.times do |i|
#     file_path = Rails.root.join("app", "assets", "images", "photo#{i + 1}.jpeg")
#     file = File.open(file_path)
#     painting.photos.attach(io: file, filename: "photo#{i + 1}.jpeg", content_type: "image/jpeg")
#     file.close
#   end

#   puts "Created #{painting.title}"
# end

puts "Finished."
