import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Global keyboard shortcuts:
//   n  new transaction
//   /  focus the search box (if the page has one)
//   ?  show this list
export default class extends Controller {
  static values = { newTransactionUrl: String }

  handle(event) {
    if (this.#typing(event) || event.metaKey || event.ctrlKey || event.altKey) return

    switch (event.key) {
      case "n":
        event.preventDefault()
        Turbo.visit(this.newTransactionUrlValue)
        break
      case "/": {
        const search = document.querySelector("input[type=search]")
        if (search) {
          event.preventDefault()
          search.focus()
        }
        break
      }
      case "?":
        alert("Shortcuts\n\nn  new transaction\n/  search transactions")
        break
    }
  }

  #typing(event) {
    const el = event.target
    return el.isContentEditable || ["INPUT", "TEXTAREA", "SELECT"].includes(el.tagName)
  }
}
