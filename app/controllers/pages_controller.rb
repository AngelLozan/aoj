class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ home about cv photography]
  before_action :load_cart

  def home
  end

  def about
  end

  def cv
  end

  def photography
  end

  def load_cart
    if session[:cart].nil?
      session[:cart] = []
      @cart = session[:cart]
    else
      @cart = Painting.find(session[:cart])
    end
  end

end
