import { Controller } from "@hotwired/stimulus"

// Navbar sticky "glass": añade .is-scrolled cuando la página se desplaza,
// para mostrar el borde inferior + sombra sutil (ver CSS .nav-glass).
export default class extends Controller {
  connect() {
    this.onScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.onScroll()
  }

  onScroll() {
    this.element.classList.toggle("is-scrolled", window.scrollY > 8)
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }
}
