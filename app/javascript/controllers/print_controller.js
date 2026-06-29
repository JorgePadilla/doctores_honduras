import { Controller } from "@hotwired/stimulus"

// Triggers the browser print dialog (used for "Imprimir / PDF").
export default class extends Controller {
  now() {
    window.print()
  }
}
