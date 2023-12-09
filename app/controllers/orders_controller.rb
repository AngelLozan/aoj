require 'mail'
require 'json'
require 'uri'
require 'net/http'

class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ new create wallet btcwallet alchemy ]
  before_action :set_order, only: %i[ show edit update destroy ]
  before_action :load_orders
  before_action :load_cart
  # before_action :load_products, only: :load_cart_prints
  # before_action :load_cart_prints

  def index
    @orders = Order.all
  end

  def show
  end

  def new
    # if @cart.nil?
    #   redirect_to paintings_url, notice: "Your cart is empty."
    # else
      @order = Order.new
    # end

    # @dev Another way to generate a client side token
    # gon.client_token = generate_client_token
  end


  def create
    @order = Order.new(order_params)

    # Add paintings from cart to order
    @cart.each do |painting|
      @order.paintings << painting
    end

    # Add prints from cart to order
    @flat_cart_arr.each do |print|
      @order.prints << print
    end

    # Payment logic, amount in cents
    @amount = (@cart.sum(&:price) + @prints_total)

    raise

    if params[:payment_method_nonce]
      # Braintree
      whole_amount = sprintf('%.2f', @amount/100.0)

      puts ">>>>>>>>>>>>>>> AMOUNT: #{@amount}<<<<<<<<<<<<<<<<<<<"

      gateway = Braintree::Gateway.new(
        :environment => :sandbox,
        :merchant_id => ENV["BRAINTREE_MERCHANT_ID"],
        :public_key => ENV["BRAINTREE_PUBLIC_KEY"],
        :private_key => ENV["BRAINTREE_PRIVATE_KEY"],
      )

      nonce_from_the_client = params[:payment_method_nonce]

      puts ">>>>>>>>>>>>>>> NONCE: #{nonce_from_the_client}<<<<<<<<<<<<<<<<<<<"

      result = gateway.transaction.sale(
        :amount => whole_amount,
        :payment_method_nonce => nonce_from_the_client,
        options: { submit_for_settlement: true }
      )

      puts ">>>>>>>>>>>>>>> RESULT: #{result}<<<<<<<<<<<<<<<<<<<"

      if result.success?
        puts "success!: #{result.transaction.id}"

        respond_to do |format|
          # byebug
          if @order.save
            @cart.each do |painting|
              painting.update(status: "sold")
            end
          # if @order.prints.any?
          #   submit_printify_order
          # end
            session[:cart] = []
            session[:prints_cart] = []
            OrderMailer.order(@order).deliver_later # Email Jaleh she has a new order
            OrderMailer.customer(@order).deliver_later # Email customer
            format.html { redirect_to paintings_url, notice: "Thank you for your order! It will arrive soon." }
          else
            format.html { render :new, status: :unprocessable_entity }
          end
        end

      elsif result.transaction
        puts "Error processing transaction:"
        puts "  code: #{result.transaction.processor_response_code}"
        puts "  text: #{result.transaction.processor_response_text}"
        redirect_to new_order_path
      else
        puts " >>>>>>>>> ERROR: #{result.errors} <<<<<<<<<<<<<"
        redirect_to new_order_path
      end

    elsif params[:stripeToken]
      # Stripe
      customer = Stripe::Customer.create({
        email: params[:stripeEmail],
        source: params[:stripeToken],
      })

      charge = Stripe::Charge.create({
        customer: customer.id,
        amount: @amount,
        description: "Rails Stripe customer",
        currency: "eur",
      })

        respond_to do |format|
          # byebug
          if @order.save
            @cart.each do |painting|
              painting.update(status: "sold")
            end
          # if @order.prints.any?
          #   submit_printify_order
          # end
            session[:cart] = []
            session[:prints_cart] = []
            OrderMailer.order(@order).deliver_later # Email Jaleh she has a new order
            OrderMailer.customer(@order).deliver_later # Email customer
            format.html { redirect_to paintings_url, notice: "Thank you for your order! It will arrive soon." }
          else
            format.html { render :new, status: :unprocessable_entity }
          end
        end

    else
      # Crypto
      puts "Crypto"
      respond_to do |format|
        if @order.save
          @cart.each do |painting|
            painting.update(status: "sold")
          end
          # if @order.prints.any?
          #   submit_printify_order
          # end
          session[:cart] = []
          session[:prints_cart] = []
          # byebug
          OrderMailer.order(@order).deliver_later # Email Jaleh she has a new order
          OrderMailer.customer(@order).deliver_later # Email customer
          flash[:notice] = "Thank you for your order! It will arrive soon."
          format.html { redirect_to paintings_url }
          format.text { render plain: "submitted" }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_order_path

  end

  def alchemy
    render json: { endpoint: ENV['ALCHEMY_ENDPOINT'], projectID: ENV['PROJECT_ID'] }, status: :ok
  end

  def wallet
    # Update to the address of the artist
    address = '0xE133a2Ae863B3fAe3dE22D4D3982B1A1fc01DaBb'
    puts ">>>>>>>>>>>>>>> ADDRESS: #{address}<<<<<<<<<<<<<<<<<<<"
    render json: { address: address }
  end

  def btcwallet
    # Update to the address of the artist
    address = 'tb1qn50cajady0d86wttx65w20kz4gweuw74n7m5rg'
    puts ">>>>>>>>>>>>>>> ADDRESS: #{address}<<<<<<<<<<<<<<<<<<<"
    render json: { address: address }
  end

  def edit
  end

  def update
    respond_to do |format|
      if @order.update(order_params)
        if @order.tracking != "" && @order.link != "" && @order.status == "complete"
          OrderMailer.tracking(@order).deliver_later # Email customer
        end
        format.html { redirect_to admin_url, notice: "Order was successfully updated." }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :admin, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @order.paintings.each do |painting|
      painting.update(order_id: nil)
      painting.update(status: "available")
    end

    @order.destroy
    respond_to do |format|
      format.html { redirect_to admin_url, notice: "Order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def order_params
    # order_paintings: [] is an array of painting ids to set from the cart before save
    params.require(:order).permit(:name, :address, :city, :state, :zip, :country, :phone, :status, :email, :note, :tracking, :link, paintings: [])
  end

  def set_order
    @order = Order.find(params[:id])
  end

  def load_orders
    @orders = Order.all
  end


  def load_cart
    if session[:cart].nil?
      session[:cart] = []
      @cart = session[:cart]
    else
      @cart = Painting.find(session[:cart])
    end
  end

  def generate_client_token
    Braintree::ClientToken.generate
  end


  def submit_printify_order
    all_items = []

    @flat_cart_arr.each do |print|
      if all_items.any? { |item| item["id"] == print["id"] }
        all_items.map do |item|
          item["quantity"] += 1 if item["id"] == print["id"]
        end
      else
        all_items << {
          "product_id": print["id"], # string
          "variant_id": print["variant"], # integer
          "quantity": 1
        }
      end
    end

    # Potentially to fill line items below? Not sure if needed
    # all_items.map do |item|
    #   {
    #     "product_id": item["id"],
    #     "variant_id": item["variant"],
    #     "quantity": item["quantity"]
    #   }
    # end

    request_body = {
      "external_id": ENV["SALES_CHANNEL_ID"],
      "label": "AOJ", # Optional
      "line_items": all_items,
      "shipping_method": 1,
      "is_printify_express": false,
      "send_shipping_notification": false,
      "address_to": {
        "first_name": order_params[:name],
        "last_name": order_params[:name],
        "email": order_params[:email],
        "phone": order_params[:phone],
        "country": order_params[:country],
        "region": "",
        "address1": order_params[:address],
        "address2": "",
        "city": order_params[:city],
        "zip": order_params[:zip]
      }
    }

      url = URI("https://api.printify.com/v1/shops/#{shop_id}/orders.json");
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true;

      request = Net::HTTP::Post.new(url)
      request["Authorization"] = "Bearer #{ENV['PRINTIFY']}"
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request["User-Agent"] = "RUBY"
      request.body = JSON.dump(request_body)

      response = http.request(request)
      # raw_data = response.read_body
      raw_data = JSON.parse(response.read_body)

      puts ">>>>>>>>>>>>>>> RAW DATA: #{raw_data}<<<<<<<<<<<<<<<<<<<"

      if raw_data["id"]
        puts ">>>>>>>>>>>>>>> ORDER ID: #{raw_data["id"]}<<<<<<<<<<<<<<<<<<<"
      else
        puts ">>>>>>>>>>>>>>> ERROR: #{raw_data}<<<<<<<<<<<<<<<<<<<"
      end
  end
end
