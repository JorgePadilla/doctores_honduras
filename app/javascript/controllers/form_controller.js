import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  connect() {
    console.log("Form controller connected")
  }

  submit() {
    // Submit the form when a filter is changed
    this.element.requestSubmit()
  }
}
