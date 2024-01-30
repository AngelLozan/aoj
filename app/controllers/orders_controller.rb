require 'mail'
require 'json'
require 'uri'
require 'net/http'
require 'base64'

class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ new create create_paypal wallet btcwallet alchemy total_price cancel_print_order]
  before_action :set_order, only: %i[ show edit update destroy ]
  before_action :load_orders
  before_action :load_cart

  def index
    @orders = Order.all

    return unless params[:query].present?

    sql_subquery = <<~SQL
      orders.name ILIKE :query
      OR orders.phone ILIKE :query
      OR orders.email ILIKE :query
      OR CAST(orders.status AS VARCHAR) ILIKE :query
    SQL
    @orders = @orders.where(sql_subquery, query: "%#{params[:query]}%")
  end

  def show
  end

  def new
      @order = Order.new
  end

  def create_paypal

    # @dev If there are prints in the cart, submit the order to Printify & get shipping to submit with paypal order.
    # @dev Works because order params (form data) is sent here from script in view.
    if @prints_total > 0
      Rails.logger.info ">>>>>>>>>>>>>>> Paypal prints being submitted <<<<<<<<<<<<<<<<<<<"
      order_id = submit_printify_order
      shipping_cost = calculate_shipping(order_id)
    end

    # @dev Create the paypal order and start the flow. Client approves and it's captured in new page.
    if (@cart.sum(&:price) + @prints_total) > 5000
      total = (@cart.sum(&:price) + @prints_total)
    else
      total = (@cart.sum(&:price) + @prints_total + shipping_cost)
    end

    Rails.logger.info ">>>>>>>>>>>>>>> Total: #{total}<<<<<<<<<<<<<<<<<<<"

    whole_amount = sprintf('%.2f', total/100.0)
    access_token = generate_access_token

    uri = URI("https://api-m.paypal.com/v2/checkout/orders")
    # uri = URI("https://api-m.sandbox.paypal.com/v2/checkout/orders")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    request['Authorization'] = "Bearer #{access_token}"
    request.body = {
      "purchase_units": [
        {
          "amount": {
            "currency_code": "USD",
            "value": "#{whole_amount}"
          }
        }
      ],
      "intent": "CAPTURE",
      "payment_source": {
        "paypal": {
          "experience_context": {
            "payment_method_preference": "IMMEDIATE_PAYMENT_REQUIRED",
            # "payment_method_selected": "PAYPAL",
            "brand_name": "The Art of Jaleh",
            "locale": "en-US",
            "landing_page": "LOGIN",
            # "shipping_preference": "SET_PROVIDED_ADDRESS",
            "user_action": "PAY_NOW",
            # "return_url": "",
            # "cancel_url": ""
          }
        }
      }
    }.to_json

    response = http.request(request)
    raw_data = JSON.parse(response.body)
    Rails.logger.info ">>>>>>>>>>>>>>> RAW DATA: #{raw_data}<<<<<<<<<<<<<<<<<<<"

    if raw_data["id"]
      Rails.logger.info "ID: #{raw_data["id"]}"
      orderID = raw_data["id"]
      return render :json => { :orderID => orderID, :paypal_order_id => order_id }, :status => :ok
    else
      Rails.logger.info " >>>>>>>>> ERROR: #{raw_data} <<<<<<<<<<<<<"
      if @order.prints.any?
        Rails.logger.info ">>>>>>>>>>>>>>> PayPal create prints being cancelled <<<<<<<<<<<<<<<<<<<"
        cancel_order(order_id)
      end
      redirect_to new_order_path, notice: "Sorry, something went wrong, please try again 🙏."
    end

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
    # @amount = (@cart.sum(&:price) + @prints_total)
    @order_id = "" # @dev Added here to make available to stripe cancel method

  if order_params[:note] == "Paypal"
    Rails.logger.info "PayPal"

    orderID = params[:paypal_order_id] # @dev From create_paypal. Added onto params and not part of forrm data, but allowed in model as int.
    access_token = generate_access_token
    uri_capture = URI("https://api-m.paypal.com/v2/checkout/orders/#{orderID}/capture")
    # uri_capture = URI("https://api-m.sandbox.paypal.com/v2/checkout/orders/#{orderID}/capture")
    http = Net::HTTP.new(uri_capture.host, uri_capture.port)
    http.use_ssl = true
    request_capture = Net::HTTP::Post.new(uri_capture.path, {'Content-Type' => 'application/json'})
    request_capture['Authorization'] = "Bearer #{access_token}"
    response_capture = http.request(request_capture)
    capture_data = JSON.parse(response_capture.body)

    Rails.logger.info ">>>>>>>>>>>>>>> RAW DATA: #{capture_data} <<<<<<<<<<<<<<<<<<<"

      if capture_data["status"] == "COMPLETED"
        Rails.logger.info ">>>>>>>>>>>>>>> SUCCESS: #{capture_data["status"]} <<<<<<<<<<<<<<<<<<<"

        # @dev Done in create_paypal
        # if @order.prints.any?
        #   Rails.logger.info ">>>>>>>>>>>>>>> Paypal prints being submitted <<<<<<<<<<<<<<<<<<<"
        #   order_id = submit_printify_order
        #   shipping_cost = calculate_shipping(order_id)
        # end

        respond_to do |format|
          # byebug
          if @order.save
            @cart.each do |painting|
              painting.update(status: "sold")
            end

            session[:cart] = []
            session[:prints_cart] = []
            OrderMailer.order(@order).deliver_later # Email Jaleh she has a new order
            OrderMailer.customer(@order).deliver_later # Email customer
            # format.html { redirect_to paintings_url, notice: "Thank you for your order! It will arrive soon." }
            return render :json => { :status => capture_data["status"] }, :status => :ok
            # format.json { render json: { status: capture_data["status"] }, status: :ok }
          else
            format.html { render :new, status: :unprocessable_entity }
            format.json { render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity }
            if @order.prints.any?
              Rails.logger.info ">>>>>>>>>>>>>>> Paypal prints being cancelled <<<<<<<<<<<<<<<<<<<"
              cancel_order(orderID)
            end
          end
        end

      else
        Rails.logger.info ">>>>>>>>>>>>>>> ERROR: #{capture_data["status"]} <<<<<<<<<<<<<<<<<<<"
        redirect_to new_order_path, notice: "Sorry, something went wrong, please try again 🙏."
        if @order.prints.any?
          Rails.logger.info ">>>>>>>>>>>>>>> Paypal error prints being cancelled <<<<<<<<<<<<<<<<<<<"
          cancel_order(orderID)
        end
      end

  elsif params[:stripeToken]
      Rails.logger.info "Stripe"


      total_price = order_params[:total]
      Rails.logger.info ">>>>>>>>>>>>>>> Total Price: #{total_price}<<<<<<<<<<<<<<<<<<<"
      # order_id = order_params[:stripe_order_id]
      # Rails.logger.info ">>>>>>>>>>>>>>> Order ID: #{order_id}<<<<<<<<<<<<<<<<<<<"

      customer = Stripe::Customer.create({
        email: params[:stripeEmail],
        source: params[:stripeToken],
      })

      charge = Stripe::Charge.create({
        customer: customer.id,
        amount: total_price, #@amount,
        description: "Rails Stripe customer",
        currency: "usd",
      })

      if @order.prints.any?
        @order_id = submit_printify_order
      end

        respond_to do |format|
          # byebug
          if @order.save
            @cart.each do |painting|
              painting.update(status: "sold")
            end

            session[:cart] = []
            session[:prints_cart] = []
            OrderMailer.order(@order).deliver_later # Email Jaleh she has a new order
            OrderMailer.customer(@order).deliver_later # Email customer
            flash[:notice] = "Thank you for your order! It will arrive soon."
            format.text { render plain: "submitted" }
            format.html { redirect_to paintings_url, notice: "Thank you for your order! It will arrive soon." }
          else
            format.html { render :new, status: :unprocessable_entity }
            if @order.prints.any?
              Rails.logger.info ">>>>>>>>>>>>>>> Stripe prints being cancelled <<<<<<<<<<<<<<<<<<<"
              cancel_order(order_id)
            end
          end
        end

    else
      # Crypto
      Rails.logger.info "Crypto"
      crypto_prints_id = order_params[:stripe_order_id] # @dev Place printifyorder in this form element for paypal and stripe.
      # @dev Do this in total price to send to the js controller.
      # if @order.prints.any?
      #   Rails.logger.info ">>>>>>>>>>>>>>> Crypto prints being submitted <<<<<<<<<<<<<<<<<<<"
      #   crypto_prints_id = submit_printify_order
      # end

      # total_price = (@amount + shipping_cost)

      respond_to do |format|
        if @order.save
          @cart.each do |painting|
            painting.update(status: "sold")
          end

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
          if @order.prints.any?
            Rails.logger.info ">>>>>>>>>>>>>>> Crypto prints being cancelled <<<<<<<<<<<<<<<<<<<"
            cancel_order(crypto_prints_id)
          end
        end
      end
    end

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_order_path
    if @order.prints.any?
      Rails.logger.info ">>>>>>>>>>>>>>> Stripe card error prints being cancelled <<<<<<<<<<<<<<<<<<<"
      cancel_order(@order_id)
    end
  end

  def alchemy
    render json: { endpoint: ENV['ALCHEMY_ENDPOINT'], projectID: ENV['PROJECT_ID'] }, status: :ok
  end

  def cancel_print_order
    Rails.logger.info ">>>>>>>>>>>>>>> CANCEL PRINT ORDER CALLED <<<<<<<<<<<<<<<<<<<"
    order_id = order_params[:stripe_order_id] # @dev Place order in this form element for paypal and stripe.
    status = cancel_order(order_id)
    if status.strip == "canceled"
      render json: { status: "success" }, status: :ok
    else
      render json: { status: "error" }, status: :ok
    end

    # redirect_to new_order_path
  end

  # @dev Posts from crypto controller with formData for @order so order params present for printify methods
  def total_price
    if @prints_total > 0
      order_id = submit_printify_order
      shipping_cost = calculate_shipping(order_id)
    end

    if (@cart.sum(&:price) + @prints_total) > 5000
      @amount = (@cart.sum(&:price) + @prints_total)
    else
      @amount = (@cart.sum(&:price) + @prints_total + shipping_cost)
    end

    Rails.logger.info ">>>>>>>>>>>>>>> AMOUNT: #{@amount}<<<<<<<<<<<<<<<<<<<"
    if shipping_cost
      render json: { amount: @amount, stripe_order_id: order_id }, status: :ok
    else
      render json: { amount: @amount, stripe_order_id: '' }, status: :ok
    end
  end

  def wallet
    # # @dev test address:
    # address = '0xE133a2Ae863B3fAe3dE22D4D3982B1A1fc01DaBb'
    # @dev Mainnet address:
    address = '0x4DE2d3C611cc080b22480Be43a32006b5b33e73'
    Rails.logger.info ">>>>>>>>>>>>>>> ADDRESS: #{address}<<<<<<<<<<<<<<<<<<<"
    render json: { address: address }
  end

  def btcwallet
    # # @dev Test address:
    # address = 'tb1qn50cajady0d86wttx65w20kz4gweuw74n7m5rg' # "2N4fKgAq7YYb8RAzAYN6s593kbyWoDLJa4o"
    # @dev Mainnet address:
    address = 'bc1q23dtx34f748phdOnektyvxnnvehqvac3r35a63'
    Rails.logger.info ">>>>>>>>>>>>>>> ADDRESS: #{address}<<<<<<<<<<<<<<<<<<<"
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
    params.require(:order).permit(:name, :address, :city, :state, :zip, :country, :phone, :status, :email, :note, :tracking, :link, :paypal_order_id, :stripe_order_id, :total, paintings: [])
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

  def generate_access_token
    client_id = ENV['PAYPAL_CLIENT_ID']
    app_secret = ENV['PAYPAL_SECRET_KEY']
    auth = Base64.strict_encode64("#{client_id}:#{app_secret}")
    url = URI.parse('https://api-m.paypal.com/v1/oauth2/token')
    # url = URI.parse('https://api-m.sandbox.paypal.com/v1/oauth2/token')

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url.path,
                                   { 'Content-Type' => 'application/x-www-form-urlencoded',
                                     'Authorization' => "Basic #{auth}" })

    request.body = 'grant_type=client_credentials'

    response = http.request(request)
    data = JSON.parse(response.body)

    data['access_token']
  end


  def submit_printify_order
    all_items = []
    shop_id = ENV["PRINTIFY_SHOP_ID"]
    external_id = SecureRandom.uuid

    # @dev Add prints from cart to order.
    # @dev If print already exists in all_items, increment quantity by 1 instead of adding a new line item
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
      "external_id": external_id, # order_params[:name],
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

      Rails.logger.info ">>>>>>>>>>>>>>> RAW DATA SUBMIT_PRINTIFY: #{raw_data}<<<<<<<<<<<<<<<<<<<"

      if raw_data["id"]
        Rails.logger.info ">>>>>>>>>>>>>>> ORDER ID: #{raw_data["id"]}<<<<<<<<<<<<<<<<<<<"
        return raw_data["id"]
      else
        Rails.logger.info ">>>>>>>>>>>>>>> ERROR SUBMIT_PRINTIFY: #{raw_data}<<<<<<<<<<<<<<<<<<<"
      end
  end

  def calculate_shipping(order_id)
    shop_id = ENV["PRINTIFY_SHOP_ID"]

      url = URI("https://api.printify.com/v1/shops/#{shop_id}/orders/#{order_id}.json");
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true;

      request = Net::HTTP::Get.new(url)
      request["Authorization"] = "Bearer #{ENV['PRINTIFY']}"
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request["User-Agent"] = "RUBY"
      # request.body = JSON.dump(request_body)

      response = http.request(request)
      raw_data = JSON.parse(response.read_body)

      Rails.logger.info ">>>>>>>>>>>>>>> RAW DATA CALCULATE SHIPPING: #{raw_data}<<<<<<<<<<<<<<<<<<<"

      total_price = raw_data["total_price"]
      Rails.logger.info ">>>>>>>>>>>>>>> TOTAL PRICE: #{total_price}<<<<<<<<<<<<<<<<<<<"
      shipping_cost = raw_data["total_shipping"]
      Rails.logger.info ">>>>>>>>>>>>>>> SHIPPING COST: #{shipping_cost}<<<<<<<<<<<<<<<<<<<"

      if raw_data["total_shipping"]
        return shipping_cost
      else
        Rails.logger.info ">>>>>>>>>>>>>>> ERROR CALCULATE SHIPPING: #{raw_data}<<<<<<<<<<<<<<<<<<<"
      end
  end

  def cancel_order(order_id)
    shop_id = ENV["PRINTIFY_SHOP_ID"]

      url = URI("https://api.printify.com/v1/shops/#{shop_id}/orders/#{order_id}/cancel.json");
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true;

      request = Net::HTTP::Post.new(url)
      request["Authorization"] = "Bearer #{ENV['PRINTIFY']}"
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request["User-Agent"] = "RUBY"
      # request.body = JSON.dump(request_body)

      response = http.request(request)
      raw_data = JSON.parse(response.read_body)

      Rails.logger.info ">>>>>>>>>>>>>>> RAW DATA CANCEL PRINTIFY: #{raw_data}<<<<<<<<<<<<<<<<<<<"

      status = raw_data["status"]
      Rails.logger.info ">>>>>>>>>>>>>>> Status: #{status}<<<<<<<<<<<<<<<<<<<"


      if status.strip == "cancelled"
        Rails.logger.info ">>>>>>>>>>>>>>> Order #{order_id} cancelled<<<<<<<<<<<<<<<<<<<"
      else
        Rails.logger.info ">>>>>>>>>>>>>>> ERROR CANCEL PRINTIFY: #{raw_data}<<<<<<<<<<<<<<<<<<<"
      end
      return status
  end

end
