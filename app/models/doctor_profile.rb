class DoctorProfile < ApplicationRecord
  belongs_to :user
  has_many :doctor_establishments, dependent: :destroy
  has_many :establishments, through: :doctor_establishments
  has_many :doctor_services, dependent: :destroy
  has_many :services, through: :doctor_services

  # ActiveStorage attachment for profile image
  has_one_attached :image

  validates :name, presence: true
  validates :specialization, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :state, presence: true

  # Validate image file type and size
  validate :acceptable_image

  private

  def acceptable_image
    return unless image.attached?

    unless image.blob.byte_size <= 5.megabyte
      errors.add(:image, "es demasiado grande (máximo 5MB)")
    end

    acceptable_types = [ "image/jpeg", "image/png", "image/jpg", "image/gif" ]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "debe ser JPEG, PNG o GIF")
    end
  end
end
