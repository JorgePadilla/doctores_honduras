class Agenda::PatientsController < Agenda::BaseController
  def index
    @patients = unique_patients
  end

  def show
    @patient_name = params[:id] # Using patient_name as identifier
    @appointments = current_doctor_profile.appointments
      .where(patient_name: @patient_name)
      .order(appointment_date: :desc, start_time: :desc)

    if @appointments.empty?
      redirect_to agenda_patients_path, alert: "Paciente no encontrado."
    end
  end

  def search
    query = params[:q].to_s.strip
    return render(json: []) if query.length < 2

    patients = current_doctor_profile.appointments
      .select("DISTINCT ON (patient_name) patient_name, patient_phone, patient_email, patient_user_id")
      .where("patient_name ILIKE :q OR patient_email ILIKE :q", q: "%#{query}%")
      .order(:patient_name, created_at: :desc)
      .limit(10)

    render json: patients.map { |p|
      {
        name: p.patient_name,
        phone: p.patient_phone,
        email: p.patient_email,
        patient_user_id: p.patient_user_id
      }
    }
  end

  private

  def unique_patients
    current_doctor_profile.appointments
      .select("patient_name, patient_phone, patient_email, patient_user_id, COUNT(*) as appointment_count, MAX(appointment_date) as last_visit")
      .group(:patient_name, :patient_phone, :patient_email, :patient_user_id)
      .order("last_visit DESC")
  end
end
