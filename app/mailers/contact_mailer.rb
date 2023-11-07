class ContactMailer < ApplicationMailer


  def contact(contact)
    # @email = 'art@jsadravi.com'
    @email = 'scottloz@protonmail.com'
    @contact = contact
    mail(to: @email, subject: @contact.subject)
  end
  
end
