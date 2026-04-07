class GamesController < ApplicationController
  before_action :set_game, only: [ :show, :host, :start, :reveal, :advance ]

  def new
    @game = Game.new
  end

  def create
    @game = Game.new
    if @game.save
      session[:host_game_id] = @game.id
      redirect_to host_game_path(@game)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    redirect_to host_game_path(@game)
  end

  def host
    unless session[:host_game_id] == @game.id
      redirect_to root_path, alert: "Host access only."
      return
    end
    @listing = @game.current_listing
    @players = @game.players.order(:created_at)
  end

  def start
    unless session[:host_game_id] == @game.id
      redirect_to root_path
      return
    end

    @game.update!(state: "playing", current_round: 0)
    broadcast_reload(@game)
    redirect_to host_game_path(@game)
  end

  def reveal
    unless session[:host_game_id] == @game.id
      redirect_to root_path
      return
    end

    @game.update!(state: "revealing")
    @game.score_round!
    @game.reload

    broadcast_reload(@game)
    redirect_to host_game_path(@game)
  end

  def advance
    unless session[:host_game_id] == @game.id
      redirect_to root_path
      return
    end

    if @game.last_round?
      @game.update!(state: "finished")
    else
      @game.update!(state: "playing", current_round: @game.current_round + 1)
    end

    broadcast_reload(@game)
    redirect_to host_game_path(@game)
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  # Broadcast a Turbo Stream that triggers all player pages to reload themselves
  def broadcast_reload(game)
    Turbo::StreamsChannel.broadcast_action_to(
      game.channel_name,
      action: :replace,
      target: "game-reload-trigger",
      html: "<div id='game-reload-trigger' data-controller='game-reload'></div>"
    )
  end
end
