require 'faker'

puts "cleaning database..."

Painting.destroy_all

puts "Now creating some paintings"

paintings = []
paintings << { title: Faker::commerce.unique.product_name, description: Faker::Hipster.sentence(word_count: rand(4..8)), price: rand(5000..100_00).to_i }

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


puts 'Finished.'
