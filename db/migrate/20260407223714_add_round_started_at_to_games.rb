class AddRoundStartedAtToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :round_started_at, :datetime
  end
end
