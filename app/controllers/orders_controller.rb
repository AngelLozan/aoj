class OrdersController < ApplicationController

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
end
