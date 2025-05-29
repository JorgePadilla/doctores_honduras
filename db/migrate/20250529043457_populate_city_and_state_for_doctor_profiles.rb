class PopulateCityAndStateForDoctorProfiles < ActiveRecord::Migration[8.0]
  def up
    # Get all doctor profiles
    doctor_profiles = DoctorProfile.all
    
    # List of departments (states) in Honduras
    departments = [
      "Atlántida",
      "Choluteca",
      "Colón",
      "Comayagua",
      "Copán",
      "Cortés",
      "El Paraíso",
      "Francisco Morazán",
      "Gracias a Dios",
      "Intibucá",
      "Islas de la Bahía",
      "La Paz",
      "Lempira",
      "Ocotepeque",
      "Olancho",
      "Santa Bárbara",
      "Valle",
      "Yoro"
    ]
    
    # Map of major cities to their departments
    city_to_department = {
      "Tegucigalpa" => "Francisco Morazán",
      "San Pedro Sula" => "Cortés",
      "La Ceiba" => "Atlántida",
      "Choloma" => "Cortés",
      "El Progreso" => "Yoro",
      "Choluteca" => "Choluteca",
      "Comayagua" => "Comayagua",
      "Puerto Cortés" => "Cortés",
      "La Lima" => "Cortés",
      "Danlí" => "El Paraíso",
      "Juticalpa" => "Olancho",
      "Catacamas" => "Olancho",
      "Tela" => "Atlántida",
      "Santa Rosa de Copán" => "Copán",
      "Siguatepeque" => "Comayagua",
      "Villanueva" => "Cortés",
      "Tocoa" => "Colón",
      "Olanchito" => "Yoro",
      "Santa Bárbara" => "Santa Bárbara",
      "Nacaome" => "Valle",
      "La Paz" => "La Paz",
      "Gracias" => "Lempira",
      "Yoro" => "Yoro",
      "Intibucá" => "Intibucá",
      "La Esperanza" => "Intibucá",
      "Trujillo" => "Colón",
      "Roatán" => "Islas de la Bahía",
      "Nueva Ocotepeque" => "Ocotepeque",
      "Puerto Lempira" => "Gracias a Dios"
    }
    
    doctor_profiles.each do |profile|
      # Skip if already has city and state
      next if profile.city.present? && profile.state.present?
      
      # Parse the location field to extract city and state
      location = profile.address || ""
      
      # Try to extract city and state from location
      city = nil
      state = nil
      
      # Check if the location contains any of the known cities
      city_to_department.each do |city_name, department_name|
        if location.include?(city_name)
          city = city_name
          state = department_name
          break
        end
      end
      
      # If city/state not found, use default values
      city ||= "Tegucigalpa"
      state ||= "Francisco Morazán"
      
      # Update the profile
      profile.update_columns(
        city: city,
        state: state
      )
    end
  end
  
  def down
    # This migration is not reversible
  end
end
