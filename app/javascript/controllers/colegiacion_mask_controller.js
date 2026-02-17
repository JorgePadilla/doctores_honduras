import { Controller } from "@hotwired/stimulus"

// Mask for Colegio Médico de Honduras number: XX-XXXXX
export default class extends Controller {
  connect() {
    this.element.addEventListener("input", this.applyMask.bind(this))
    this.element.addEventListener("keydown", this.handleBackspace.bind(this))
  }

  applyMask(e) {
    let value = e.target.value.replace(/[^0-9]/g, "")
    if (value.length > 7) value = value.slice(0, 7)
    if (value.length > 2) {
      value = value.slice(0, 2) + "-" + value.slice(2)
    }
    e.target.value = value
  }

  handleBackspace(e) {
    if (e.key === "Backspace" && e.target.selectionStart === 3 && e.target.value[2] === "-") {
      e.target.value = e.target.value.slice(0, 2)
      e.preventDefault()
    }
  }
}
