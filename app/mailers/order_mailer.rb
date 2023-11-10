class OrderMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.order.subject
  #
  def order(_order)
    # @email = 'art@jsadravi.com'
    @email = 'scottloz@protonmail.com'
    @order = _order
    mail( to: @email, subject: "You have a new order on your site!")
  end

  def customer(_order)
    @order = _order
    mail( to: @order.email, subject: "Thank you for your order!" )
  end

  def tracking(_order)
    @order = _order
    mail(to: @order.email, subject: "Your order has shipped!")
  end
  
end
