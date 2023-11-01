class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ new create wallet btcwallet ]
  before_action :set_order, only: %i[ show edit update destroy ]
  before_action :set_cart, only: %i[ new create ]
  before_action :load_orders
  before_action :load_cart

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
    # Add paintings from car <%= f.input :email, label: 'Your email address', input_html: { class: 'form-control' } %> to order
    @cart.each do |painting|
      @order.paintings << painting
    end

    # Payment logic, amount in cents
    @amount = @cart.sum(&:price)

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
          byebug
          if @order.save
            @cart.each do |painting|
              painting.update(status: "sold")
            end
            session[:cart] = []
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
          byebug
          if @order.save
            @cart.each do |painting|
              painting.update(status: "sold")
            end
            session[:cart] = []
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
          session[:cart] = []
          byebug
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
    params.require(:order).permit(:name, :address, :phone, :status, :email, paintings: [])
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

  def set_cart
    @cart = Painting.find(session[:cart])
  end

  def generate_client_token
    Braintree::ClientToken.generate
  end
end
