class DoctorProfile < ApplicationRecord
  belongs_to :user
  belongs_to :specialty, optional: true
  belongs_to :subspecialty, optional: true
  belongs_to :department, optional: true
  belongs_to :city, optional: true
  has_many :doctor_establishments, dependent: :destroy
  has_many :establishments, through: :doctor_establishments
  has_many :doctor_services, dependent: :destroy
  has_many :services, through: :doctor_services

  # Direct S3 URL for profile image
  attribute :image_url, :string

  validates :name, presence: true
  validates :department_id, presence: true
  validates :city_id, presence: true

  # Validate image URL format
  validate :valid_image_url

  private

  def valid_image_url
    return if image_url.blank?

    unless image_url =~ URI::DEFAULT_PARSER.make_regexp
      errors.add(:image_url, "debe ser una URL válida")
    end
  end
end
