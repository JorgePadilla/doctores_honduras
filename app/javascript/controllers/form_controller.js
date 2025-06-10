import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = ["filterForm", "submitButton", "loadingIndicator"]
  static values = {
    frame: String
  }
  
  connect() {
    console.log("Form controller connected")
    
    // Get the frame ID from the data attribute
    const frameId = this.element.dataset.turboFrame
    if (frameId) {
      this.frameValue = frameId
      
      // Listen for turbo:frame-load on the document
      document.addEventListener("turbo:frame-load", this.hideLoading.bind(this))
    }
  }
  
  disconnect() {
    // Clean up event listener when controller is disconnected
    document.removeEventListener("turbo:frame-load", this.hideLoading.bind(this))
  }

  submit() {
    // Submit the form when a filter is changed
    this.showLoading()
    this.element.requestSubmit()
  }
  
  showLoading() {
    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.classList.remove("hidden")
    }
    
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add("opacity-75")
    }
  }
  
  hideLoading(event) {
    // Only respond to events for our frame
    if (event && event.target && event.target.id === this.frameValue) {
      if (this.hasLoadingIndicatorTarget) {
        this.loadingIndicatorTarget.classList.add("hidden")
      }
      
      if (this.hasSubmitButtonTarget) {
        this.submitButtonTarget.disabled = false
        this.submitButtonTarget.classList.remove("opacity-75")
      }
    }
  }
}
