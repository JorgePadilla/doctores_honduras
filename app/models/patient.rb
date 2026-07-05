class Patient < ApplicationRecord
  belongs_to :doctor_profile
  belongs_to :user, optional: true

  has_one :clinical_record, dependent: :destroy
  has_many :appointments, dependent: :nullify

  validates :name, presence: true

  scope :ordered, -> { order(:name) }

  # Resuelve (find-or-create) la identidad canónica del paciente para un médico
  # a partir de los campos crudos que trae una cita. Los pacientes registrados
  # se identifican por user_id; los walk-ins por nombre normalizado dentro del
  # roster del médico.
  def self.resolve_for(doctor_profile_id:, name:, user_id: nil, phone: nil, email: nil, identity_document: nil)
    return nil if doctor_profile_id.blank? || name.blank?

    patient =
      if user_id.present?
        find_or_initialize_by(doctor_profile_id: doctor_profile_id, user_id: user_id)
      else
        where(doctor_profile_id: doctor_profile_id, user_id: nil)
          .where("lower(btrim(name)) = ?", name.to_s.strip.downcase)
          .first_or_initialize
      end

    patient.name              = name              if name.present?
    patient.phone             = phone             if phone.present?
    patient.email             = email             if email.present?
    patient.identity_document = identity_document if identity_document.present?
    patient.save! if patient.new_record? || patient.changed?
    patient
  end

  def display_contact
    [ email, phone ].compact_blank.join(" · ")
  end

  # Atajo hacia la ficha clínica (expediente Elite).
  def allergies
    clinical_record&.allergies
  end

  def allergies?
    allergies.present?
  end
end
