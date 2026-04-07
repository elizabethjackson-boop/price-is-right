import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    gameId: Number,
    playerId: Number,
    gameState: String,
    currentRound: Number,
    totalRounds: Number,
    gameCode: String,
    token: String
  }

  connect() {
    // Listen for ActionCable broadcasts via Turbo Stream (handled automatically by turbo_stream_from tag)
    // We also listen for custom events dispatched from Turbo
    this.element.addEventListener("turbo:before-stream-render", this.handleStreamRender.bind(this))
    document.addEventListener("game:reveal", this.handleReveal.bind(this))
    document.addEventListener("game:advance", this.handleAdvance.bind(this))
    document.addEventListener("game:started", this.handleStarted.bind(this))
  }

  disconnect() {
    document.removeEventListener("game:reveal", this.handleReveal.bind(this))
    document.removeEventListener("game:advance", this.handleAdvance.bind(this))
    document.removeEventListener("game:started", this.handleStarted.bind(this))
  }

  handleStreamRender(event) {
    // Let Turbo handle stream renders normally
  }

  handleReveal(event) {
    // Page will be reloaded via Turbo Stream broadcast
  }

  handleAdvance(event) {
    // Page will be reloaded via Turbo Stream broadcast
  }

  handleStarted(event) {
    // Page will be reloaded via Turbo Stream broadcast
  }

  formatAmount(event) {
    const input = event.target
    const raw = input.value.replace(/[^0-9]/g, "")
    if (raw) {
      input.value = Number(raw).toLocaleString()
    } else {
      input.value = ""
    }
  }

  submitGuess(event) {
    event.preventDefault()
    const form = document.getElementById("guess-form")
    if (form) form.requestSubmit()
  }
}
