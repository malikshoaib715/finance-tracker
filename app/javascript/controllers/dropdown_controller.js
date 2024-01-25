import { Controller } from "@hotwired/stimulus"

// Toggles a menu and closes it on outside click or Escape.
export default class extends Controller {
  static targets = ["menu", "button"]

  toggle() {
    this.menuTarget.classList.contains("hidden") ? this.open() : this.close()
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) this.close()
  }
}
