class DoctorProfile < ApplicationRecord
  include HasUploadableImage

  AVAILABLE_LANGUAGES = ["Español", "Inglés", "Francés", "Portugués", "Alemán", "Italiano", "Mandarín", "Otro"].freeze
  PREFIXES = ["Dr.", "Dra.", "Lic.", "Ing.", "Téc.", "Enf.", "Msc.", "PhD."].freeze

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

  def display_name
    prefix.present? ? "#{prefix} #{name}" : name
  end
end
