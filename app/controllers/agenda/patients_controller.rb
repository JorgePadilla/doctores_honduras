class Agenda::PatientsController < Agenda::BaseController
  # Roster de pacientes canónicos del médico (identidad estable, ya no el string
  # patient_name). Disponible para Profesional+; el expediente clínico (ficha,
  # alergias) es Elite y se gestiona en Agenda::ClinicalRecordsController.
  def index
    @patients = current_doctor_profile.patients
      .left_joins(:appointments)
      .select("patients.*, COUNT(appointments.id) AS appointment_count, MAX(appointments.appointment_date) AS last_visit")
      .group("patients.id")
      .order(Arel.sql("MAX(appointments.appointment_date) DESC NULLS LAST"))
  end

  def show
    @patient = current_doctor_profile.patients.find(params[:id])
    @appointments = @patient.appointments.includes(:doctor_branch).order(appointment_date: :desc, start_time: :desc)
    @clinical_record = @patient.clinical_record
  end

  # JSON autocomplete para el formulario de citas. Busca por nombre, correo o
  # DNI (normalizando dígitos, ignora guiones). Siempre scopeado a los pacientes
  # del médico (current_doctor_profile.patients) — no filtra los de otros.
  def search
    query = params[:q].to_s.strip
    return render(json: []) if query.length < 2

    digits = query.gsub(/\D/, "")
    patients = current_doctor_profile.patients
      .where(
        "name ILIKE :q OR email ILIKE :q OR (:digits <> '' AND regexp_replace(coalesce(identity_document, ''), '[^0-9]', '', 'g') LIKE :dq)",
        q: "%#{query}%", digits: digits, dq: "%#{digits}%"
      )
      .order(:name)
      .limit(10)

    render json: patients.map { |p|
      { id: p.id, name: p.name, phone: p.phone, email: p.email,
        identity_document: p.identity_document, patient_user_id: p.user_id }
    }
  end
end
