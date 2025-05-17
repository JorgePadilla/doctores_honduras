class Supplier < ApplicationRecord
  has_many :products, dependent: :destroy
  
  validates :name, presence: true
  validates :phone, presence: true
end
