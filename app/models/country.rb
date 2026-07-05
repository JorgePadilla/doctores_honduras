class Country < ApplicationRecord
  has_many :departments, dependent: :restrict_with_error
  has_many :cities, through: :departments

  validates :name, presence: true, uniqueness: true
end
