json.extract! painting, :id, :description, :price, :title, :discount_code, :created_at, :updated_at
json.url painting_url(painting, format: :json)
