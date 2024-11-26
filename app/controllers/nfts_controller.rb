require 'mail'
require 'json'
require 'uri'
require 'net/http'

class NftsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :nfts, :endpoint ]
  before_action :load_cart
  before_action :load_orders


  def nfts
  end

  def endpoint
    render json: { endpoint: ENV['POLYGON_API'] }, status: :ok
  end


  # def set_image_urls
  #   render json: { message: "Image URLs updated successfully" }
  # end

  private


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
