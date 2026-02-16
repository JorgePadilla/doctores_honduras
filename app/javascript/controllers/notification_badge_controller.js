import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Badge is rendered server-side
    // Could add polling here for real-time updates
  }
}
