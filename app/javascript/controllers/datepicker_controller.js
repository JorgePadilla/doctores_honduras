import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

const Spanish = {
  firstDayOfWeek: 1,
  weekdays: {
    shorthand: ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"],
    longhand: ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"]
  },
  months: {
    shorthand: ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"],
    longhand: ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
  },
  rangeSeparator: " a ",
  weekAbbreviation: "Sem",
  scrollTitle: "Desplázate para cambiar",
  toggleTitle: "Haz clic para cambiar",
  ordinal: () => "°"
}

export default class extends Controller {
  connect() {
    this.fp = flatpickr(this.element, {
      locale: Spanish,
      dateFormat: "Y-m-d",
      altInput: true,
      altFormat: "j \\de F, Y",
      minDate: "today",
      disableMobile: true,
      onChange: (_selectedDates, dateStr) => {
        this.element.value = dateStr
        this.element.dispatchEvent(new Event("change", { bubbles: true }))
        this.element.dispatchEvent(new Event("input", { bubbles: true }))
      }
    })
  }

  disconnect() {
    if (this.fp) {
      this.fp.destroy()
    }
  }
}
