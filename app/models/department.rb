class Department < ApplicationRecord
  belongs_to :country
  has_many :cities

  validates :name, presence: true, uniqueness: true

  # Returns an array of department names for use in select dropdowns
  def self.names_for_select
    pluck(:name)
  end
end
