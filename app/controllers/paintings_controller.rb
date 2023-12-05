require 'mail'
require 'json'
require 'uri'
require 'net/http'

class PaintingsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show add_to_cart remove_from_cart ]
  before_action :set_painting, only: %i[ show edit update destroy ]
  before_action :initalize_cart, only: %i[load_cart add_to_cart remove_from_cart ]
  before_action :load_cart # Load for all pages since in navbar, only: %i[ index show add_to_cart remove_from_cart ]
  # before_action :load_products, only: :load_cart_prints
  before_action :load_cart_prints
  before_action :load_orders

  def index
    @paintings = Painting.all.order(created_at: :desc).page params[:page]
  end

  def show
  end

  def new
    @painting = Painting.new
  end


  def edit
  end

  def create
    adjusted_params = painting_params.merge(price: (painting_params[:price].to_f * 100).to_i)
    @painting = Painting.new(adjusted_params)
    respond_to do |format|
      if @painting.save
        format.html { redirect_to painting_url(@painting), notice: "Painting was successfully created." }
        format.json { render :show, status: :created, location: @painting }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @painting.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @painting.update(painting_params)
        format.html { redirect_to painting_url(@painting), notice: "Painting was successfully updated." }
        format.json { render :show, status: :ok, location: @painting }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @painting.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @painting.destroy
    respond_to do |format|
      format.html { redirect_to paintings_url, notice: "Painting was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def admin
    @paintings = Painting.all
  end


  def add_to_cart
    id = params[:id].to_i
    session[:cart] << id unless session[:cart].include?(id)
    redirect_to new_order_path
  end

  def remove_from_cart
    id = params[:id].to_i
    session[:cart].delete(id)
    redirect_to paintings_path
  end

  private

   # @dev Cart functionality

  # @dev only display cart if the painting isn't in cart already (not etsy)
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

    def set_painting
      @painting = Painting.find(params[:id])
    end

    def painting_params
      params.require(:painting).permit(:description, :status, :price, :title, :discount_code, photos: [])
    end

    def initalize_cart
      session[:cart] ||= []
    end
end
