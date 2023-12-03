class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ home about cv photography commissions privacy terms ]
  before_action :load_cart
  before_action :load_orders

  def home
  end

  def about
  end

  def cv
  end

  def photography
  end

  def commissions
  end

  def privacy
  end

  def terms
  end


  def load_cart
    if session[:cart].nil?
      session[:cart] = []
      @cart = session[:cart]
    else
      @cart = Painting.find(session[:cart])
    end
  end

  def load_orders
    @orders = Order.all
  end

end
