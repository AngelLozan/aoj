require 'mail'
require 'json'
require 'uri'
require 'net/http'

class ContactsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ new create ]
  before_action :set_contact, only: %i[ show edit update destroy ]
  before_action :load_cart
  # before_action :load_products, only: :load_cart_prints
  before_action :load_cart_prints
  before_action :load_orders


  def new
    @contact = Contact.new
  end


  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if verify_recaptcha(model: @contact) && @contact.save
        ContactMailer.contact(@contact).deliver_later
        format.html { redirect_to new_contact_url, notice: "Thank you for contacting me, I'll be in touch as soon as possible." }
        format.json { render :new, status: :created }
      elsif !verify_recaptcha(model: @contact)
        format.html do
          redirect_to new_contact_url, status: :unprocessable_entity, notice: "Please complete recaptcha 🤖"
        end
        format.json { render json: object.errors, status: :unprocessable_entity }
      else
        format.html { render :new, status: :unprocessable_entity, notice: "Something is missing 🤔" }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end


  private
    def set_contact
      @contact = Contact.find(params[:id])
    end

    def contact_params
      params.require(:contact).permit(:name, :email, :subject, :message)
    end

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
