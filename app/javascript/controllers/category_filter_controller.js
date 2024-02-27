import { Controller } from "@hotwired/stimulus"

// Shows only the categories that match the selected transaction kind.
// Each <optgroup> carries data-kind="expense" or data-kind="income".
export default class extends Controller {
  static targets = ["kind", "select"]

  connect() {
    this.filter()
  }

  filter() {
    const kind = this.kindTargets.find((input) => input.checked)?.value
    if (!kind) return

    for (const group of this.selectTarget.querySelectorAll("optgroup")) {
      const matches = group.dataset.kind === kind
      group.hidden = !matches
      group.disabled = !matches
    }

    const selected = this.selectTarget.selectedOptions[0]
    if (selected?.parentElement?.disabled) this.selectTarget.value = ""
  }
}
