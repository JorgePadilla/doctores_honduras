import { Controller } from "@hotwired/stimulus"

// Navbar sticky "glass": añade .is-scrolled al desplazar (borde+sombra, ver
// .nav-glass) y controla el menú hamburguesa móvil (reemplaza el script inline).
export default class extends Controller {
  static targets = ["mobileMenu"]

  connect() {
    this.onScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.onScroll()
  }

  onScroll() {
    this.element.classList.toggle("is-scrolled", window.scrollY > 8)
  }

  toggleMobile() {
    if (this.hasMobileMenuTarget) this.mobileMenuTarget.classList.toggle("hidden")
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }
}
