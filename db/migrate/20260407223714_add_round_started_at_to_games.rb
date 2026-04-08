class AddRoundStartedAtToGames < ActiveRecord::Migration[8.1]
  def change
    # round_started_at was removed: the column was written on round transitions
    # but never read — score_round! derives speed rank from guess created_at order
    # rather than elapsed time. Keeping the migration as a no-op preserves the
    # migration history without adding the unused column.
  end
end
