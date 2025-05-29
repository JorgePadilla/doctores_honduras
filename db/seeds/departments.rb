# Seeds for Honduras departments (states)

# Check if Department model exists, if not, create it
if defined?(Department)
  puts "Department model exists, seeding departments..."
  
  # List of the 18 departments of Honduras
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
  
  # Create departments if they don't exist
  departments.each do |name|
    Department.find_or_create_by!(name: name)
  end
  
  puts "Created #{Department.count} departments"
else
  # If Department model doesn't exist, just output the list for reference
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
  
  puts "Department model not found. Here are the departments of Honduras for reference:"
  puts departments.inspect
  
  # Create a constant in the global namespace for reference
  Object.const_set('HONDURAS_DEPARTMENTS', departments.freeze) unless defined?(HONDURAS_DEPARTMENTS)
end
