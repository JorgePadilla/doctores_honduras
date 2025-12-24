import { Controller } from "@hotwired/stimulus"

// Controlador para manejar los filtros de doctores
export default class extends Controller {
  static targets = ["form", "specialty", "service"]
  
  connect() {
    console.log("Filter controller connected")
  }
  
  // Enviar el formulario automáticamente cuando cambia un filtro
  filterChange() {
    this.formTarget.requestSubmit()
  }
}
