import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { gameId: Number }

  connect() {
    this.knownCount = 0
    this.pollInterval = setInterval(() => {
      this.refreshPlayerList()
    }, 1500)
  }

  disconnect() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval)
      this.pollInterval = null
    }
  }

  async refreshPlayerList() {
    try {
      const response = await fetch(`/games/${this.gameIdValue}/status`, {
        headers: { "Accept": "application/json" }
      })
      const data = await response.json()

      // Only update DOM if player count changed
      if (data.player_names.length !== this.knownCount) {
        this.knownCount = data.player_names.length
        this.renderPlayerList(data.player_names)
      }
    } catch (e) {
      // Silently fail
    }
  }

  renderPlayerList(names) {
    if (names.length === 0) {
      this.element.innerHTML = `<p style="font-size:15px; color:rgba(255,255,255,0.35); margin-bottom:12px;">Waiting for players to join...</p>`
    } else {
      const pills = names.map(name =>
        `<div style="background:rgba(255,255,255,0.1); border-radius:20px; padding:6px 16px; font-size:15px; font-weight:600; color:rgba(255,255,255,0.85);">${name}</div>`
      ).join("")
      this.element.innerHTML = `
        <div style="margin-bottom:12px;">
          <div style="font-size:13px; letter-spacing:2px; color:rgba(255,255,255,0.4); margin-bottom:12px">${names.length} PLAYER${names.length !== 1 ? "S" : ""} JOINED</div>
          <div style="display:flex; flex-wrap:wrap; gap:8px; justify-content:center;">
            ${pills}
          </div>
        </div>
      `
    }
  }
}
