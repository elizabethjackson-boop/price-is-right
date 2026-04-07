class PlayersController < ApplicationController
  before_action :set_game_by_code

  def join
    @player = Player.new
  end

  def create
    @player = @game.players.build(name: params[:name])
    if @player.save
      session[:player_token] = @player.token
      broadcast_player_list_update
      redirect_to player_game_path(@game.code, @player.token)
    else
      render :join, status: :unprocessable_entity
    end
  end

  def show
    @player = @game.players.find_by!(token: params[:token])
    @listing = @game.current_listing
    @guess = @player.current_guess(@game.current_round)
  end

  def guess
    @player = @game.players.find_by!(token: params[:token])

    unless session[:player_token] == @player.token
      redirect_to player_game_path(@game.code, @player.token), alert: "Unauthorized"
      return
    end

    raw_amount = params[:amount].to_s.gsub(/[^0-9]/, "").to_i

    if raw_amount <= 0
      redirect_to player_game_path(@game.code, @player.token), alert: "Please enter a valid amount"
      return
    end

    existing_guess = @player.guesses.find_by(round: @game.current_round)

    if existing_guess
      existing_guess.update!(amount: raw_amount)
    else
      @player.guesses.create!(round: @game.current_round, amount: raw_amount)
    end

    broadcast_guess_count
    redirect_to player_game_path(@game.code, @player.token)
  end

  private

  def set_game_by_code
    @game = Game.find_by!(code: params[:game_code].upcase)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Game not found. Check your code and try again."
  end

  def broadcast_guess_count
    guesses_in = @game.guesses.where(round: @game.current_round).count
    player_count = @game.players.count
    html = "<p style=\"font-size:14px; color:rgba(255,255,255,0.3); margin-bottom:16px\">#{guesses_in} / #{player_count} guesses received</p>"
    Turbo::StreamsChannel.broadcast_update_to(
      @game.channel_name,
      target: "guess_count",
      html: html
    )
  end

  def broadcast_player_list_update
    players = @game.players.order(:created_at)
    html = ApplicationController.render(
      partial: "games/player_list",
      locals: { players: players }
    )
    Turbo::StreamsChannel.broadcast_update_to(
      @game.channel_name,
      target: "player_list",
      html: html
    )
  end
end
