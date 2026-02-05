class Supplier < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :department, optional: true
  belongs_to :city, optional: true
  has_many :products, dependent: :destroy
  has_many :lead_contacts, dependent: :destroy

  validates :name, presence: true
  validates :phone, presence: true
end
