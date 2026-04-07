import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // When this element is injected via Turbo Stream, reload the current page
    Turbo.visit(window.location.href, { action: "replace" })
  }
}
