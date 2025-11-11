import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["specialty", "subspecialty"]

  connect() {
    console.log('SubspecialtyController connected')
    this.updateSubspecialties()
  }

  updateSubspecialties() {
    console.log('updateSubspecialties called')
    const specialtyId = this.specialtyTarget.value
    const subspecialtySelect = this.subspecialtyTarget

    console.log('Specialty ID:', specialtyId)
    console.log('Subspecialty select element:', subspecialtySelect)

    // Clear existing options
    subspecialtySelect.innerHTML = '<option value="">Selecciona una subespecialidad (opcional)</option>'

    if (specialtyId) {
      console.log('Fetching subespecialties for specialty:', specialtyId)
      // Fetch subespecialties for the selected specialty
      fetch(`/specialties/${specialtyId}/subspecialties.json`)
        .then(response => {
          console.log('Response status:', response.status)
          return response.json()
        })
        .then(subspecialties => {
          console.log('Received subespecialties:', subspecialties)
          subspecialties.forEach(subspecialty => {
            const option = document.createElement('option')
            option.value = subspecialty.id
            option.textContent = subspecialty.name
            subspecialtySelect.appendChild(option)
          })
          console.log('Added', subspecialties.length, 'subespecialties to dropdown')
        })
        .catch(error => console.error('Error fetching subespecialties:', error))
    }
  }
}