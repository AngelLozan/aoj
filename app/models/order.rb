class Order < ApplicationRecord
  has_many :paintings
  validates :address, presence: true # @dev => street address
  validates :phone, presence: true
  validates :email, presence: true
  validates :country, presence: true
  validates :city, presence: true
  validates :zip, presence: true

  enum :status, { open: 0, complete: 1 }
end
