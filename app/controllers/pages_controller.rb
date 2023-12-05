require 'mail'
require 'json'
require 'uri'
require 'net/http'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ home about cv photography commissions privacy terms ]
  before_action :load_cart
  # before_action :load_products, only: :load_cart_prints
  before_action :load_cart_prints
  before_action :load_orders

  def home
  end

  def about
  end

  def cv
  end

  def photography
  end

  def commissions
  end

  def privacy
  end

  def terms
  end

  private

  def load_cart
    if session[:cart].nil?
      session[:cart] = []
      @cart = session[:cart]
    else
      @cart = Painting.find(session[:cart])
    end
  end

  def load_cart_prints
    shop_id = ENV['PRINTIFY_SHOP_ID']
    url = URI("https://api.printify.com/v1/shops/#{shop_id}/products.json");
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true;

    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "Bearer #{ENV['PRINTIFY']}"
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    request["User-Agent"] = "RUBY"
    # request.body = JSON.dump({}) # if you need to send a body with the request...

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
          'description' => product['description'],
          'image' => 'abstractart.png',
          'price' => product['variants'].first['price']
        }
      else
        {
          'id' => product['id'],
          'title' => product['title'],
          'description' => product['description'],
          'image' => product["images"].first["src"],
          'price' => product['variants'].first['price']
        }
      end

    end

    @products = products

    if session[:prints_cart].nil?
      session[:prints_cart] = []
      @prints_cart = session[:prints_cart]
    else
      # Return array of prints in cart
      @prints_cart = session[:prints_cart].map do |id|
        @products.select { |product| product['id'] == id }
      end
    end
  end


  def load_orders
    @orders = Order.all
  end

end
