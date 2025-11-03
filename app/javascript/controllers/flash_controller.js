import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  static targets = ["message"]

  connect() {
    // Auto-remove flash message after animation completes
    if (this.element.classList.contains('flash-auto-dismiss')) {
      setTimeout(() => {
        this.remove()
      }, 5000) // 5 seconds total (4.7s animation delay + 0.3s animation)
    }
  }

  remove() {
    this.element.classList.add('animate-slide-out-up')

    // Remove element after animation completes
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  dismiss(event) {
    event.preventDefault()
    this.remove()
  }
}