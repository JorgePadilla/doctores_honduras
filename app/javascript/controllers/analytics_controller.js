import { Controller } from "@hotwired/stimulus"

// Sends a named analytics event to Ahoy on interaction.
// Usage:
//   <a href="https://wa.me/504..."
//      data-controller="analytics"
//      data-analytics-name-value="Contact Click"
//      data-analytics-props-value='{"kind":"whatsapp","viewable_type":"DoctorProfile","viewable_id":12}'
//      data-action="click->analytics#track">WhatsApp</a>
export default class extends Controller {
  static values = {
    name: { type: String, default: "Click" },
    props: { type: Object, default: {} }
  }

  track() {
    if (window.ahoy && typeof window.ahoy.track === "function") {
      try {
        window.ahoy.track(this.nameValue, this.propsValue)
      } catch (e) {
        // never let tracking break a user action
      }
    }
  }
}
