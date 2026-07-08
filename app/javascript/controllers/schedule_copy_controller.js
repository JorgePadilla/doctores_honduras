import { Controller } from "@hotwired/stimulus"

// Copies Monday's opening hours to Tuesday–Friday within one branch entry.
// Rows are marked with data-schedule-row="<day_of_week>" (1 = Monday).
export default class extends Controller {
  copyMonday(event) {
    event.preventDefault()

    const rows = {}
    this.element.querySelectorAll("[data-schedule-row]").forEach(row => {
      rows[row.dataset.scheduleRow] = row
    })

    const monday = rows["1"]
    if (!monday) return
    const [mOpens, mCloses] = monday.querySelectorAll("input[type=time]")

    for (const day of ["2", "3", "4", "5"]) {
      const row = rows[day]
      if (!row) continue
      const [opens, closes] = row.querySelectorAll("input[type=time]")
      if (opens && mOpens) opens.value = mOpens.value
      if (closes && mCloses) closes.value = mCloses.value
    }
  }
}
