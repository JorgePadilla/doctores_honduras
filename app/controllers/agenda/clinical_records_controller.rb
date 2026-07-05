class Agenda::ClinicalRecordsController < Agenda::BaseController
  before_action :require_elite
  before_action :set_patient

  def new
    if @patient.clinical_record
      redirect_to edit_agenda_patient_clinical_record_path(@patient)
    elsif clinical_record_limit_reached?
      redirect_to agenda_patient_path(@patient), alert: limit_message
    else
      @clinical_record = @patient.build_clinical_record
    end
  end

  def create
    if @patient.clinical_record
      redirect_to edit_agenda_patient_clinical_record_path(@patient)
      return
    elsif clinical_record_limit_reached?
      redirect_to agenda_patient_path(@patient), alert: limit_message
      return
    end

    @clinical_record = @patient.build_clinical_record(clinical_record_params)
    if @clinical_record.save
      redirect_to agenda_patient_path(@patient), notice: "Ficha clínica creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @clinical_record = @patient.clinical_record
    redirect_to new_agenda_patient_clinical_record_path(@patient) if @clinical_record.nil?
  end

  def update
    @clinical_record = @patient.clinical_record
    if @clinical_record.update(clinical_record_params)
      redirect_to agenda_patient_path(@patient), notice: "Ficha clínica actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_patient
    @patient = current_doctor_profile.patients.find(params[:patient_id])
  end

  def clinical_record_params
    params.require(:clinical_record).permit(:allergies, :chronic_conditions, :current_medications, :blood_type, :medical_history, :notes)
  end

  def clinical_record_limit_reached?
    limit = plan_patient_limit
    return false if limit.nil?

    current_doctor_profile.clinical_records.count >= limit
  end

  def plan_patient_limit
    current_doctor_profile.user.subscription&.subscription_plan&.patient_limit
  end

  def limit_message
    "Alcanzaste el límite de #{plan_patient_limit} registros clínicos de tu plan Elite. Sube de nivel para agregar más."
  end
end
