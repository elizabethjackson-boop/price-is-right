class GamesController < ApplicationController
  before_action :set_game, only: [ :show, :host, :status, :start, :reveal, :advance ]

  def new
    @game = Game.new
  end

  def create
    @game = Game.new
    if @game.save
      redirect_to host_game_path(@game)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    redirect_to host_game_path(@game)
  end

  def host
    @listing = @game.current_listing
    @players = @game.players.order(:created_at)
    @leaderboard = @game.leaderboard(limit: 5)
    @round_results = @game.round_results if @game.state == "revealing"
    @best_guesses = @game.best_guesses(limit: 5) if @game.state == "finished"
  end

  # Lightweight JSON endpoint for polling — no view rendering, just game state
  def status
    guesses_count = @game.guesses.where(round: @game.current_round).count
    players = @game.players.order(:created_at).pluck(:name)
    render json: {
      state: @game.state,
      current_round: @game.current_round,
      guesses_count: guesses_count,
      player_count: players.length,
      player_names: players
    }
  end

  def start
    @game.update!(state: "playing", current_round: 0)
    broadcast_reload(@game)
    redirect_to host_game_path(@game)
  end

  def reveal
    @game.update!(state: "revealing")
    @game.reload  # clear association cache before scoring
    @game.score_round!
    @game.reload

    broadcast_reload(@game)
    redirect_to host_game_path(@game)
  end

  def advance
    if @game.last_round?
      @game.update!(state: "finished")
    else
      @game.update!(
        state: "playing",
        current_round: @game.current_round + 1
      )
    end

    broadcast_reload(@game)
    redirect_to host_game_path(@game)
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def broadcast_reload(game)
    Turbo::StreamsChannel.broadcast_action_to(
      game.channel_name,
      action: :replace,
      target: "game-reload-trigger",
      html: "<div id='game-reload-trigger' data-controller='game-reload'></div>"
    )
  end
end
