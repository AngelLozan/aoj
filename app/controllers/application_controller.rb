class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :load_cart_prints

  private

  def load_cart_prints
    time = Time.now.to_i

    @products = Rails.cache.fetch("#{time}_products", expires_in: 1.hour) do
      shop_id = ENV['PRINTIFY_SHOP_ID']
      url = URI("https://api.printify.com/v1/shops/#{shop_id}/products.json");
      puts "=========================================="
      puts "FROM APPLICATION CONTROLLER"
      puts "=========================================="
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true;

      request = Net::HTTP::Get.new(url)
      request["Authorization"] = "Bearer #{ENV['PRINTIFY']}"
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request["User-Agent"] = "RUBY"
      request["Cache-Control"] = "private, max-age=3600, no-revalidate"    # request.body = JSON.dump({}) # if you need to send a body with the request...

      response = http.request(request)
      # products = response.read_body
      raw_data = JSON.parse(response.read_body)

      products = raw_data["data"]

      products = products.map do |product|
        p "=========================================="
        p "Product is: #{product["id"]}"
        p "=========================================="

        if product["images"].empty?
          {
            'id' => product['id'],
            'title' => product['title'],
            'description' => product['description'].gsub(/\.:\s.*(?:\n|\z)/, ''),
            'image' => 'abstractart.png',
            'price' => product['variants'].first['price']
          }
        else
          {
            'id' => product['id'],
            'title' => product['title'],
            'description' => product['description'].gsub(/\.:\s.*(?:\n|\z)/, ''),
            'image' => product["images"].first["src"],
            'price' => product['variants'].first['price']
          }
        end

      end
    end

    @products = @products

    if session[:prints_cart].nil?
      session[:prints_cart] = []
      @prints_cart = session[:prints_cart]
    else
      # Return array of prints in cart
      @prints_cart = session[:prints_cart].map do |id|
        @products.select { |product| product['id'] == id }
      end

      @flat_cart_arr = @prints_cart.flatten

      @prints_total = @flat_cart_arr.reduce(0) do |sum, product|
        sum + product["price"]
      end

      puts "=========================================="
      puts "Cart is:"
      puts @prints_cart.flatten.inspect
      puts "total is: "
      puts @prints_total
      puts "=========================================="
    end
  end
end
