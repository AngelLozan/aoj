require "faker"

puts "cleaning database..."

Painting.destroy_all
User.destroy_all
Order.destroy_all
Contact.destroy_all

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
puts "Created #{let_the_church_say.title}"

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
puts "Created #{four_generations.title}"

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
puts "Created #{kindred_souls.title}"

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
puts "Created #{community_of_faith.title}"

free_to_shine = Painting.create!({ title: "Free to shine", price: 160000, description:
  """
  Original painting by Jaleh Sadravi

  acrylic on canvas, 23.5 inches by 23.5 inches, 60 X 60 cm/s

  """
})
  file_path_5 = Rails.root.join("app", "assets", "images", "free_to_shine.jpeg")
  file_5 = File.open(file_path_5)
  free_to_shine.photos.attach(io: file_5, filename: "free_to_shine.jpeg", content_type: "image/jpeg")
  file_5.close
puts "Created #{free_to_shine.title}"

we_call_their_names_so_we_remember = Painting.create!({ title: "We call their names so we remember", price: 240000, description:
  """
  Original painting by Jaleh Sadravi

  Acrylic on canvas. Size: 27.5 inches x 40 inches (Painting does not come framed.)

  """
})
  file_path_6 = Rails.root.join("app", "assets", "images", "we_call_their_names_so_we_remember.jpeg")
  file_6 = File.open(file_path_6)
  we_call_their_names_so_we_remember.photos.attach(io: file_6, filename: "we_call_their_names_so_we_remember.jpeg", content_type: "image/jpeg")
  file_6.close
puts "Created #{we_call_their_names_so_we_remember.title}"

our_family_is_our_strength = Painting.create!({ title: "Our family is our strength", price: 114500, description:
  """
  Original painting by Jaleh Sadravi

  acrylic on canvas

  25.5 x 15.5 inches, 60x 40 cm/s

  """
})
  file_path_7 = Rails.root.join("app", "assets", "images", "our_family_is_our_strength.jpeg")
  file_7 = File.open(file_path_7)
  our_family_is_our_strength.photos.attach(io: file_7, filename: "our_family_is_our_strength.jpeg", content_type: "image/jpeg")
  file_7.close
puts "Created #{our_family_is_our_strength.title}"

family_is_love = Painting.create!({ title: "Family is love", price: 112000, description:
  """
  Original painting by Jaleh Sadravi

  acrylic on canvas

  20x 15.5 inches

  """
})
  file_path_8 = Rails.root.join("app", "assets", "images", "family_is_love.jpeg")
  file_8 = File.open(file_path_8)
  family_is_love.photos.attach(io: file_8, filename: "family_is_love.jpeg", content_type: "image/jpeg")
  file_8.close
puts "Created #{family_is_love.title}"

following_the_spirit = Painting.create!({ title: "Following the spirit", price: 152500, description:
  """
  Original painting by Jaleh Sadravi

  25 inches by 25 inches, acrylic on canvas

  """
})
  file_path_9 = Rails.root.join("app", "assets", "images", "following_the_spirit.jpeg")
  file_9 = File.open(file_path_9)
  following_the_spirit.photos.attach(io: file_9, filename: "following_the_spirit.jpeg", content_type: "image/jpeg")
  file_9.close
puts "Created #{following_the_spirit.title}"

in_the_shelter_of_your_arms = Painting.create!({ title: "In the shelter of your arms", price: 125000, description:
  """
  Original canvas painting by Jaleh Sadravi

  40 x 50 cm

  (15.7 x 19.7 inches)

  """
})
  file_path_10 = Rails.root.join("app", "assets", "images", "in_the_shelter_of_your_arms.jpeg")
  file_10 = File.open(file_path_10)
  in_the_shelter_of_your_arms.photos.attach(io: file_10, filename: "in_the_shelter_of_your_arms.jpeg", content_type: "image/jpeg")
  file_10.close
puts "Created #{in_the_shelter_of_your_arms.title}"

passing_down_our_wisdom = Painting.create!({ title: "Passing down our wisdom, expanding our roots", price: 182500, description:
  """
  Original painting by Jaleh Sadravi

  acrylic on canvas, 40x50 cm, 15.5 x 19.5 inches

  Inspiration for this painting - 'My mother was my first country; the first place I ever lived' poem by Nayyirah Waheed

  """
})
  file_path_11 = Rails.root.join("app", "assets", "images", "passing_down_our_wisdom.jpeg")
  file_11 = File.open(file_path_11)
  passing_down_our_wisdom.photos.attach(io: file_11, filename: "passing_down_our_wisdom.jpeg", content_type: "image/jpeg")
  file_11.close
puts "Created #{passing_down_our_wisdom.title}"

gathering_of_women = Painting.create!({ title: "Gathering of women", price: 261000, description:
  """
  Original painting by Jaleh Sadravi

  acrylic on canvas

  Large black canvas with vibrant colors depicting a group of women gathering together.

  Size: 25'x35' inches

  """
})
  file_path_12 = Rails.root.join("app", "assets", "images", "gathering_of_women.jpeg")
  file_12 = File.open(file_path_12)
  gathering_of_women.photos.attach(io: file_12, filename: "gathering_of_women.jpeg", content_type: "image/jpeg")
  file_12.close
puts "Created #{gathering_of_women.title}"

loving_care_of_community = Painting.create!({ title: "Loving care of community", price: 265000, description:
  """
  Original painting by Jaleh Sadravi

  Size: 27.5 inches x 40 inches

  Painting does not come framed.

  """
})
  file_path_13 = Rails.root.join("app", "assets", "images", "loving_care_of_community.jpeg")
  file_13 = File.open(file_path_13)
  loving_care_of_community.photos.attach(io: file_13, filename: "loving_care_of_community.jpeg", content_type: "image/jpeg")
  file_13.close
puts "Created #{loving_care_of_community.title}"


connected_by_our_love = Painting.create!({ title: "Connected by our love", price: 222200, description:
  """
  Original painting by Jaleh Sadravi

  acrylic on canvas

  25'x35' inches

  """
})
  file_path_14 = Rails.root.join("app", "assets", "images", "connected_by_our_love.jpeg")
  file_14 = File.open(file_path_14)
  connected_by_our_love.photos.attach(io: file_14, filename: "connected_by_our_love.jpeg", content_type: "image/jpeg")
  file_14.close
puts "Created #{connected_by_our_love.title}"




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
