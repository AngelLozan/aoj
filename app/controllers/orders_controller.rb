class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create]
  before_action :set_order, only: %i[ show edit update destroy ]

  def index
    @orders = Order.all
  end

  def new
    @order = Order.new
    @cart.each do |painting|
      @order.paintings << painting
    end
  end

  def create

  end

  def show
    @order = Order.find(params[:id])
  end

  def edit
  end
  
  def update
  end

  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to admin_url, notice: "Order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
