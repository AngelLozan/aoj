class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create]
  before_action :set_order, only: %i[ show edit update destroy ]
  before_action :load_cart

  def index
    @orders = Order.all
  end

  def new
    @order = Order.new
    @cart.each do |painting|
      @order.order_paintings << painting
    end
  end

  def create
    @order = Order.new(order_params)
    # TODO: Add logic to set order status to "open" and create order
  end

  def show
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

  def load_cart
    if session[:cart].nil?
      session[:cart] = []
      @cart = session[:cart]
    else
      @cart = Painting.find(session[:cart])
    end
  end

  private

  def order_params
    # order_paintings: [] is an array of painting ids to set from the cart before save
    params.require(:order).permit(:address, :phone, :status, order_paintings:[])
  end

  def set_order
    @order = Order.find(params[:id])
  end


end
