Rails.application.routes.draw do
  root "games#new"

  resources :games, only: [ :new, :create, :show ] do
    member do
      get  :host
      get  :status
      post :start
      post :reveal
      post :advance
    end
  end

  # Player join flow
  get  "/play/:game_code",              to: "players#join",  as: :join_game
  post "/play/:game_code",              to: "players#create"
  get  "/play/:game_code/:token",       to: "players#show",  as: :player_game
  post "/play/:game_code/:token/guess", to: "players#guess", as: :player_guess

  get "up" => "rails/health#show", as: :rails_health_check
end
