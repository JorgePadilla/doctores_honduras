class PatientProfile < ApplicationRecord
  belongs_to :user
  belongs_to :country, optional: true
  belongs_to :department, optional: true
  belongs_to :city, optional: true

  validates :name, presence: true
  validates :identity_document, presence: true
  validates :phone, presence: true
  validates :country_id, presence: true
  validate :identity_document_has_13_digits

  private

  # DNI de Honduras: 13 dígitos (se permiten guiones, p.ej. 0801-1990-12345).
  def identity_document_has_13_digits
    return if identity_document.blank?

    unless identity_document.gsub(/\D/, "").length == 13
      errors.add(:identity_document, "debe tener 13 dígitos")
    end
  end
end
