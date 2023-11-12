require 'json'

class NftsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :nfts ]
  # after_action :set_image_urls, only: [ :nfts  ]
  before_action :load_cart
  before_action :load_orders

  def nfts
  end


  def set_image_urls
    render json: { message: "Image URLs updated successfully" }
  end

  private

  def set_image_urls
    puts request.body
    data = JSON.parse(request.body.read)
    @image_urls = data["images"]
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
