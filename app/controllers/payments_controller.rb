class PaymentsController < ApplicationController
  before_action :set_cart
  skip_before_action :authenticate_user!, only: %i[new create]

  def new
  end

  def create
    # Amount in cents
    @amount = @cart.sum(&:price)
    # @amount = (current_user.cart_total * 100).to_i
    # @amount = number_to_currency(@cart.sum(&:price) / 100.00, :unit=> '€')
    customer = Stripe::Customer.create({
      email: params[:stripeEmail],
      source: params[:stripeToken],
    })

    charge = Stripe::Charge.create({
      customer: customer.id,
      amount: @amount,
      description: 'Rails Stripe customer',
      currency: 'eur',
    })

    @cart.each do |painting|
      painting.update(status: "sold")
    end

    session[:cart] = []
    flash[:notice] = "Thank you for your purchase!"

    redirect_to paintings_path

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_payment_path
  end

  private

  def set_cart
    @cart = Painting.find(session[:cart])
  end
end
