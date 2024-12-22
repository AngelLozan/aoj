require 'mail'
require 'json'
require 'uri'
require 'net/http'
require 'nokogiri'
require 'byebug'

class PrintsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index , :show, :add_to_cart_prints, :remove_from_cart_prints ]
  before_action :initalize_cart_prints, only: %i[ load_cart_prints add_to_cart_prints remove_from_cart_prints ]
  # before_action :load_products, only: :load_cart_prints
  before_action :load_cart
  # before_action :load_cart_prints
  before_action :load_orders

  def index
    @products = load_products
    if !params[:query] || params[:query].empty?
      @products = Kaminari.paginate_array(@products).page(params[:page]).per(10)
    end

    return unless params[:query].present?

    sql_subquery = <<~SQL
      products.title ILIKE :query
    SQL
    # @products = @products.select(sql_subquery, query: "%#{params[:query]}%").page params[:page]
    @products = @products.select {|p| p["title"].downcase.include?(params[:query].downcase)}
    @products = Kaminari.paginate_array(@products).page(params[:page]).per(10)

  end

  def prints_admin
    @products = load_products
  end

  def show
    # Pass the product id as a param from the index page? Or JS controller
    shop_id = ENV['PRINTIFY_SHOP_ID']
    product_id = sanitize_id(params[:id])
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
    raw_data = JSON.parse(response.read_body)

    print = raw_data
    images = [];
    print["images"].each do |image|
      images << image["src"]
    end

    parsed_description = Nokogiri::HTML.parse(print['description'])

    default_variant = print['variants'].find { |variant| variant['is_default'] == true && variant['is_enabled'] == true}

    variants = print['variants']

    if default_variant
      price = default_variant['price']
    else
      first_variant = variants.first
      price = first_variant['price']
    end

    if print["images"].empty?

      @print = {
        'id' => print['id'],
        'title' => print['title'],
        'description' => parsed_description.text,
        'image' => 'abstractart.png',
        'price' => price,
        'tags' => print['tags'],
        'variants' => variants || [default_variant]
      }
    else
      @print = {
        'id' => print['id'],
        'title' => print['title'],
        'description' => parsed_description.text,
        'images' => images,
        'price' => price,
        'tags' => print['tags'],
        'variants' => variants || [default_variant]
      }
    end

    @print

  end

  def add_to_cart_prints
    id = params[:id]
    variant_id = params[:variant_id]
    session[:prints_cart] << {"id" => id, "variant_id" => variant_id }
    redirect_to new_order_path
  end

  def remove_from_cart_prints
    id = params[:id]
    print_cart = session[:prints_cart]
    index = print_cart.index { |item| item["id"] == id } # && item["variant_id"] == params[:variant_id] TO DO
    print_cart.delete_at(index) if index

    # print_cart.delete_at((print_cart.find { |item| item["id"] == id }) || print_cart.length)
    # print_cart.delete_at(print_cart.index(id) || print_cart.length)
    # session[:prints_cart].delete(id)
    if print_cart.empty? && session[:cart].empty?
      redirect_to prints_path
    else
      redirect_to new_order_path
    end
  end

  def unpublish_print
    begin
      id = sanitize_id(params[:id])
      shop_id = ENV['PRINTIFY_SHOP_ID']
      url = URI("https://api.printify.com/v1/shops/#{shop_id}/products/#{id}/publishing_failed.json");
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true;
      request = Net::HTTP::Post.new(url)
      request["Authorization"] = "Bearer #{ENV['PRINTIFY']}"
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request["User-Agent"] = "RUBY"
      request.body = JSON.dump({
        reason: "I need to remove this print from my shop."
      })

      response = http.request(request)
      raw_data = JSON.parse(response.read_body)
      Rails.logger.info("==========================================")
      Rails.logger.info("Response is: #{raw_data}")
      Rails.logger.info("==========================================")

      if raw_data = "#{id}"
        flash[:notice] = "Print has been unpublished 👍, please remove it from your shop in the printify console."
      else
        flash[:notice] = "Could not unpublish the print 🚨, please try again or contact support."
      end

      redirect_to prints_admin_path
    rescue StandardError => e
      Rails.logger.error("==========================================")
      Rails.logger.error("Error is: #{e}")
      Rails.logger.error("==========================================")
      flash[:notice] = "Could not unpublish the print 🚨, please try again.
      Error: #{e}"
      redirect_to print_admin_paths
    end
  end

  def publish_print
    begin
      id = sanitize_id(params[:id])
      shop_id = ENV['PRINTIFY_SHOP_ID']
      url = URI("https://api.printify.com/v1/shops/#{shop_id}/products/#{id}/publishing_succeeded.json");
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true;
      request = Net::HTTP::Post.new(url)
      request["Authorization"] = "Bearer #{ENV['PRINTIFY']}"
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request["User-Agent"] = "RUBY"
      request.body = JSON.dump({
        external: {
          id: "#{id}",
          handle: "https://theartofjaleh.com/prints/show/#{id}"
        }
      })

      response = http.request(request)
      raw_data = JSON.parse(response.read_body)
      Rails.logger.info("==========================================")
      Rails.logger.info("Response is: #{raw_data}")
      Rails.logger.info("==========================================")

      if raw_data = "#{id}"
        flash[:notice] = "Print has been published 👍, please verify it shows as such on your Printify shop."
      else
        flash[:notice] = "Could not publish the print 🚨, please try again."
      end

      redirect_to print_path(id: id)
    rescue StandardError => e
      Rails.logger.error("==========================================")
      Rails.logger.error("Error is: #{e}")
      Rails.logger.error("==========================================")
      flash[:notice] = "Could not publish the print 🚨, please try again.
      Error: #{e}"
      redirect_to print_path(id: id)
    end

  end

  private

  def load_products
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
      raw_data = JSON.parse(response.read_body)

      products = raw_data["data"]

      products = products.map do |product|
        p "=========================================="
        p "Product is: #{product["id"]}"
        p "=========================================="

        next if product['visible'] != true # Skip if product is not published

        parsed_description = Nokogiri::HTML.parse(product['description'])

        default_variant = product['variants'].find { |variant| variant['is_default'] == true && variant['is_enabled'] == true}


        if default_variant
          price = default_variant['price']
          variant = default_variant['id']
        else
          first_variant = product['variants'].first
          price = first_variant['price']
          variant = first_variant['id']
        end


        if product["images"].empty?
          {
            'id' => product['id'],
            'title' => product['title'],
            'description' => parsed_description.text,
            'image' => 'abstractart.png',
            'price' => price,
            'tags' => product['tags'], # product['variants'].first['price'],
            'variant' => variant # product['variants'].first['id']
          }
        else
          {
            'id' => product['id'],
            'title' => product['title'],
            'description' => parsed_description.text,
            'image' => product["images"].first["src"],
            'price' => price,
            'tags' => product['tags'],
            'variant' => variant
          }
        end

      end
    end
    @products = @products
  end

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

  def sanitize_id(id)
    ActionController::Base.helpers.sanitize(id)
  end

end
