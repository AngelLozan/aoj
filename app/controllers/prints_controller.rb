require 'mail'
require 'json'
require 'uri'
require 'net/http'

class PrintsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index , :show, :add_to_cart_prints, :remove_from_cart_prints ]
  before_action :initalize_cart_prints, only: %i[ load_cart_prints add_to_cart_prints remove_from_cart_prints ]
  # before_action :load_products, only: :load_cart_prints
  before_action :load_cart
  # before_action :load_cart_prints
  before_action :load_orders

  def index

    @products = Rails.cache.fetch("products", expires_in: 1.hour) do
      shop_id = ENV['PRINTIFY_SHOP_ID']
      url = URI("https://api.printify.com/v1/shops/#{shop_id}/products.json");
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true;

      request = Net::HTTP::Get.new(url)
      request["Authorization"] = "Bearer #{ENV['PRINTIFY']}"
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request["User-Agent"] = "RUBY"
      request["Cache-Control"] = "private, max-age=3600, no-revalidate"
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
            'description' => product['description'].gsub(/\.:\s.*(?:\n|\z)/, ''),
            'image' => 'abstractart.png',
            'price' => product['variants'].first['price'],
            'variant' => product['variants'].first['id']
          }
        else
          {
            'id' => product['id'],
            'title' => product['title'],
            'description' => product['description'].gsub(/\.:\s.*(?:\n|\z)/, ''),
            'image' => product["images"].first["src"],
            'price' => product['variants'].first['price'],
            'variant' => product['variants'].first['id']
          }
        end

      end
    end
    @products = @products
    @products = Kaminari.paginate_array(@products).page(params[:page]).per(10)

  end

  def show
    # Pass the product id as a param from the index page? Or JS controller
    shop_id = ENV['PRINTIFY_SHOP_ID']
    product_id = params[:id]
    url = URI("https://api.printify.com/v1/shops/#{shop_id}/products/#{product_id}.json");
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

    print = raw_data

    if print["images"].empty?
      @print = {
        'id' => print['id'],
        'title' => print['title'],
        'description' => print['description'].gsub(/\.:\s.*(?:\n|\z)/, ''),
        'image' => 'abstractart.png',
        'price' => print['variants'].first['price']
      }
    else
      @print = {
        'id' => print['id'],
        'title' => print['title'],
        'description' => print['description'].gsub(/\.:\s.*(?:\n|\z)/, ''),
        'image' => print["images"].first["src"],
        'price' => print['variants'].first['price'],
      }
    end

    # @variants = product['variants'].map do |variant|
    #   {
    #     'variant_id' => variant['id'],
    #     'variant_title' => variant['title'],
    #     'variant_price' => variant['price'],
    #     'variant_image' => variant['image']['src']
    #   }
    # end
    @print = @print

  end

  def add_to_cart_prints
    id = params[:id]
    session[:prints_cart] << id
    redirect_to new_order_path
  end

  def remove_from_cart_prints
    id = params[:id]
    session[:prints_cart].delete(id)
    redirect_to prints_path
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

  def initalize_cart_prints
    session[:prints_cart] ||= []
  end

  def load_orders
    @orders = Order.all
  end

end
