class Product < ApplicationRecord
  belongs_to :supplier

  validates :name, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :category, presence: true

  scope :active, -> { where(active: true) }
  scope :featured, -> { where(featured: true) }
end
