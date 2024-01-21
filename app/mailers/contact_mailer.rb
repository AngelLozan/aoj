class ContactMailer < ApplicationMailer


  def contact(contact)
    @contact = contact
    mail(to: @contact.email, subject: @contact.subject)
  end


end
