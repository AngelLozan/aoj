class Order < ApplicationRecord
  has_many :paintings
  validates :address, presence: true
  validates :phone, presence: true
  enum :status, { open: 0, complete: 1 }
end
