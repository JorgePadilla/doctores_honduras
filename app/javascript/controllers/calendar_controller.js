import { Controller } from "@hotwired/stimulus"

// Click an empty area of a day column to start a new appointment prefilled with
// that date. Clicks on an existing appointment (a link) are ignored.
export default class extends Controller {
  newAt(event) {
    if (event.target.closest("a")) return // clicked an existing appointment

    const track = event.currentTarget
    const date = track.dataset.date
    if (!date) return

    window.location = `/agenda/appointments/new?date=${encodeURIComponent(date)}`
  }
}
