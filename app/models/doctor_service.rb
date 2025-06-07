class DoctorService < ApplicationRecord
  belongs_to :doctor_profile
  belongs_to :service
end
