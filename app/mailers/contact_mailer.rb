class ContactMailer < ApplicationMailer


  def contact(contact)
    @contact = contact
    mail(to: 'hellojaleh@gmail.com', subject: @contact.subject)
  end


end
