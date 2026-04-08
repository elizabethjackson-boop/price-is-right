import { Controller } from "@hotwired/stimulus"

// Unified host polling controller — handles both the waiting lobby (player list)
// and the playing state (guess count) from a single status request per poll cycle.
// Replaces the separate player-list-poll controller to avoid two independent
// controllers both polling /games/:id/status simultaneously.
function escapeHtml(s) {
  return String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
}

export default class extends Controller {
  static values = { gameId: Number }

  connect() {
    this.knownPlayerCount = 0
    this.pollInterval = setInterval(() => {
      this.refreshStatus()
    }, 1000)
  }

  disconnect() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval)
      this.pollInterval = null
    }
  }

  async refreshStatus() {
    try {
      const response = await fetch(`/games/${this.gameIdValue}/status`, {
        headers: { "Accept": "application/json" }
      })
      const data = await response.json()

      // Update guess count label (playing state)
      const guessEl = document.getElementById("guess-count-text")
      if (guessEl) {
        guessEl.textContent = `${data.guesses_count} / ${data.player_count} guesses received`
      }

      // Update player list (waiting/lobby state).
      // This controller may be mounted on #player-list-area itself (waiting state)
      // or on a sibling element (playing state); fall back to getElementById either way.
      const playerListEl =
        (this.element.id === "player-list-area" ? this.element : null) ||
        document.getElementById("player-list-area")

      if (playerListEl && data.player_names.length !== this.knownPlayerCount) {
        this.knownPlayerCount = data.player_names.length
        this.renderPlayerList(playerListEl, data.player_names)
      }
    } catch (e) {
      // Silently fail — transient network errors shouldn't crash the host screen
    }
  }

  renderPlayerList(element, names) {
    if (names.length === 0) {
      element.innerHTML = `<p style="font-size:15px; color:rgba(255,255,255,0.35); margin-bottom:12px;">Waiting for players to join...</p>`
    } else {
      const pills = names.map(name =>
        `<div style="background:rgba(255,255,255,0.1); border-radius:20px; padding:6px 16px; font-size:15px; font-weight:600; color:rgba(255,255,255,0.85);">${escapeHtml(name)}</div>`
      ).join("")
      const count = escapeHtml(String(names.length))
      element.innerHTML = `
        <div style="margin-bottom:12px;">
          <div style="font-size:13px; letter-spacing:2px; color:rgba(255,255,255,0.4); margin-bottom:12px">${count} PLAYER${names.length !== 1 ? "S" : ""} JOINED</div>
          <div style="display:flex; flex-wrap:wrap; gap:8px; justify-content:center;">
            ${pills}
          </div>
        </div>
      `
    }
  }
}
