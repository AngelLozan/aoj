class Contact < ApplicationRecord
  validates :name, :email, :subject, :message, presence: true

  def headers
    {
      subject: subject,
      to: 'scottloz@protonmail.com',
      from: %("#{name}" <#{email}>)
    }
  end
  
end
