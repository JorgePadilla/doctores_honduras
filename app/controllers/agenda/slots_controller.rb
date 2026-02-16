class Agenda::SlotsController < Agenda::BaseController
  def index
    branch = current_doctor_profile.doctor_branches.find(params[:branch_id])
    date = Date.parse(params[:date])

    slots = SlotGenerator.new(
      doctor_branch: branch,
      date: date,
      doctor_profile: current_doctor_profile
    ).generate

    render json: slots
  rescue ArgumentError, ActiveRecord::RecordNotFound
    render json: [], status: :unprocessable_entity
  end
end
