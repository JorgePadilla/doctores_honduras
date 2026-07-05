class DoctorProfile < ApplicationRecord
  include HasUploadableImage

  AVAILABLE_LANGUAGES = [ "Español", "Inglés", "Francés", "Portugués", "Alemán", "Italiano", "Mandarín", "Otro" ].freeze
  PREFIXES = [ "Dr.", "Dra.", "Lic.", "Ing.", "Téc.", "Enf.", "Msc.", "PhD." ].freeze

  has_uploadable_image :image, folder: "doctor_profiles", crop: true

  belongs_to :user
  belongs_to :specialty, optional: true
  belongs_to :subspecialty, optional: true
  belongs_to :department, optional: true
  belongs_to :city, optional: true
  has_many :doctor_establishments, dependent: :destroy
  has_many :establishments, through: :doctor_establishments
  has_many :doctor_services, dependent: :destroy
  has_many :services, through: :doctor_services
  has_many :profile_views, as: :viewable, dependent: :destroy
  has_many :doctor_branches, dependent: :destroy
  has_many :doctor_educations, dependent: :destroy
  has_many :doctor_certifications, dependent: :destroy
  has_many :secretary_assignments, dependent: :destroy
  has_many :secretaries, through: :secretary_assignments, source: :user
  has_one :agenda_setting, class_name: "DoctorAgendaSetting", dependent: :destroy
  has_many :appointments, dependent: :destroy

  accepts_nested_attributes_for :doctor_branches, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :doctor_educations, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :doctor_certifications, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :prefix, inclusion: { in: PREFIXES }, allow_blank: true
  validates :department_id, presence: true
  validates :city_id, presence: true

  # Generic placeholder specialty auto-assigned to many doctors. We avoid
  # headlining it publicly when the doctor has something more specific (B5).
  GENERAL_SPECIALTY_NAME = "Medicina General"

  def display_name
    prefix.present? ? "#{prefix} #{name}" : name
  end

  def general_specialty?
    specialty&.name == GENERAL_SPECIALTY_NAME
  end

  # Public-facing headline. Prefer the (more specific) subspecialty; otherwise
  # the specialty, unless it's the generic "Medicina General" placeholder (B5).
  def headline_specialty
    subspecialty&.name.presence || (specialty&.name unless general_specialty?)
  end

  # WhatsApp number stripped to digits only (for wa.me links). Nil when blank.
  def whatsapp_digits
    whatsapp.to_s.gsub(/\D/, "").presence
  end

  # https://wa.me/<digits> link, or nil when no WhatsApp number is set.
  def whatsapp_url
    digits = whatsapp_digits
    "https://wa.me/#{digits}" if digits
  end

  # Contact phone stripped to digits only. Nil when blank.
  def phone_digits
    phone.to_s.gsub(/\D/, "").presence
  end

  # tel:<digits> link for the "Llamar" button, or nil when no phone is set.
  def tel_url
    digits = phone_digits
    "tel:#{digits}" if digits
  end
end
