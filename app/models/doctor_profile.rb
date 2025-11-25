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

  # Virtual attribute for file upload
  attr_accessor :image_file

  validates :name, presence: true
  validates :department_id, presence: true
  validates :city_id, presence: true

  # Validate image file or URL
  validate :validate_image

  # Callback to handle file upload
  before_save :upload_image_to_s3, if: :image_file_present?

  private

  def validate_image
    if image_file.present? && image_url.present?
      errors.add(:base, "No puedes subir un archivo y especificar una URL al mismo tiempo")
    end

    if image_file.present?
      validate_image_file
    elsif image_url.present?
      validate_image_url
    end
  end

  def validate_image_file
    unless image_file.content_type.in?(%w[image/jpeg image/png image/jpg image/gif])
      errors.add(:image_file, "debe ser JPEG, PNG o GIF")
    end

    if image_file.size > 5.megabytes
      errors.add(:image_file, "es demasiado grande (máximo 5MB)")
    end
  end

  def validate_image_url
    unless image_url =~ URI::DEFAULT_PARSER.make_regexp
      errors.add(:image_url, "debe ser una URL válida")
    end
  end

  def image_file_present?
    image_file.present?
  end

  def upload_image_to_s3
    upload_service = S3UploadService.new
    self.image_url = upload_service.upload_file(image_file)

    if image_url.nil?
      errors.add(:image_file, "no se pudo subir a S3")
      throw :abort
    end
  end
end
