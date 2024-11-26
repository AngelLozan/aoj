class Painting < ApplicationRecord
  has_many_attached :photos
  belongs_to :order, optional: true
  validates :title, :description, :price, presence: true
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  enum :status, { available: 0, sold: 1 }
  paginates_per 10
end
