class OrderMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.order.subject
  #
  def order(_order)
    @email = 'art@jsadravi.com'
    @order = _order
    mail( to: @email, subject: "You have a new order on your site!")
  end
end
