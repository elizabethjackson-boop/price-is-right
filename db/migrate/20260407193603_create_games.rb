class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :state, default: "waiting", null: false
      t.integer :current_round, default: 0, null: false
      t.string :code, null: false

      t.timestamps
    end
  end
end
