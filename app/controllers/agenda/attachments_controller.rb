class Agenda::AttachmentsController < Agenda::BaseController
  before_action :require_elite
  before_action :set_appointment

  # Tipos y tamaño permitidos para resultados de laboratorio / adjuntos.
  ALLOWED_TYPES = %w[application/pdf image/jpeg image/png image/webp image/heic].freeze
  MAX_SIZE = 10.megabytes

  def create
    files = Array(params[:files]).reject(&:blank?)
    if files.empty?
      return redirect_to agenda_appointment_path(@appointment), alert: "Selecciona al menos un archivo."
    end

    rejected = []
    files.each do |file|
      if !ALLOWED_TYPES.include?(file.content_type)
        rejected << "#{file.original_filename} (tipo no permitido)"
      elsif file.size > MAX_SIZE
        rejected << "#{file.original_filename} (supera 10 MB)"
      else
        @appointment.lab_attachments.attach(file)
      end
    end

    if rejected.any?
      redirect_to agenda_appointment_path(@appointment), alert: "No se subieron: #{rejected.join(', ')}."
    else
      redirect_to agenda_appointment_path(@appointment), notice: "Adjunto(s) agregado(s)."
    end
  end

  def destroy
    attachment = @appointment.lab_attachments.find(params[:id])
    attachment.purge_later
    redirect_to agenda_appointment_path(@appointment), notice: "Adjunto eliminado."
  end

  private

  def set_appointment
    @appointment = current_doctor_profile.appointments.find(params[:appointment_id])
  end
end
