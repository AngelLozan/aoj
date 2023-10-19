class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create]
  before_action :set_order, only: %i[ show edit update destroy ]
  before_action :set_cart, only: %i[ new create ]
  before_action :load_orders

  def index
    @orders = Order.all
  end

  def show
  end

  def new
    @order = Order.new
    gon.client_token = generate_client_token
  end

  def create_paypal
    @order = Order.new(order_params)
    # Add paintings from cart to order
    @cart.each do |painting|
      @order.paintings << painting
    end

    # Payment logic, amount in cents
    @amount = @cart.sum(&:price)


    respond_to do |format|
      byebug
      if @order.save
        @cart.each do |painting|
          painting.update(status: "sold")
        end
        session[:cart] = []
        OrderMailer.order(@order).deliver_later # Email Jaleh she has a new order
        format.html { redirect_to paintings_url, notice: "Thank you for your order! It will arrive soon." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def create
    @order = Order.new(order_params)
    # Add paintings from cart to order
    @cart.each do |painting|
      @order.paintings << painting
    end

    # Payment logic, amount in cents
    @amount = @cart.sum(&:price)
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
        format.html { redirect_to paintings_url, notice: "Thank you for your order! It will arrive soon." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end

    # flash[:notice] = "Thank you for your purchase!"
    # redirect_to paintings_path

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_order_path

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
    @order.destroy
    respond_to do |format|
      format.html { redirect_to admin_url, notice: "Order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def order_params
    # order_paintings: [] is an array of painting ids to set from the cart before save
    params.require(:order).permit(:name, :address, :phone, :status, paintings: [])
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