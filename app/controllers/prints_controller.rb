require 'mail'
require 'json'
require 'uri'
require 'net/http'

class PrintsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index , :show ]
  before_action :initalize_cart_prints, only: %i[load_cart_prints add_to_cart_print remove_from_cart_print ]
  before_action :load_products, only: :load_cart_prints
  before_action :load_prints_cart
  before_action :load_orders

  def index
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



    @products = products.map do |product|
      {
        'id' => product['id'],
        'title' => product['title'],
        'description' => product['description'],
        'image' => product['images'][0]['src'],
        'price' => product['variants'][0]['price']
      }
    end

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

    product = raw_data["data"]


    @product = {
      'id' => product['id'],
      'title' => product['title'],
      'description' => product['description'],
      'image' => product['images'][0]['src'],
      'price' => product['variants'][0]['price']
    }

    # @variants = product['variants'].map do |variant|
    #   {
    #     'variant_id' => variant['id'],
    #     'variant_title' => variant['title'],
    #     'variant_price' => variant['price'],
    #     'variant_image' => variant['image']['src']
    #   }
    # end
  end

  def add_to_cart_print
    id = params[:id].to_i
    session[:cart] << id unless session[:cart].include?(id)
    redirect_to new_order_path
  end

  def remove_from_cart_print
    id = params[:id].to_i
    session[:cart].delete(id)
    redirect_to prints_path
  end

  private

  def load_products
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

    @products = products.map do |product|
      {
        'id' => product['id'],
        'title' => product['title'],
        'description' => product['description'],
        'image' => product['images'][0]['src'],
        'price' => product['variants'][0]['price']
      }
    end
  end

  def load_cart_prints
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

  def initalize_cart_prints
    session[:prints_cart] ||= []
  end
end
