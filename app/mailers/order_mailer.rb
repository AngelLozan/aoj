class OrderMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.order.subject
  #
  def order(_order)
    @order = _order
    mail( to: 'hellojaleh@gmail.com', subject: "You have a new order on your site!")
  end

  def customer(_order)
    attachments.inline['aoj.jpeg'] = File.read("#{Rails.root}/app/assets/images/aoj.jpeg")
    @order = _order
    mail( to: @order.email, subject: "Thank you for your order!" )
  end

  def tracking(_order)
    attachments.inline['aoj.jpeg'] = File.read("#{Rails.root}/app/assets/images/aoj.jpeg")
    @order = _order
    mail(to: @order.email, subject: "Your order has shipped!")
  end

end
