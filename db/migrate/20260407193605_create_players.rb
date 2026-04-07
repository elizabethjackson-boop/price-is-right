class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players do |t|
      t.references :game, null: false, foreign_key: true
      t.string :name
      t.string :token
      t.integer :score, default: 0, null: false

      t.timestamps
    end
  end
end
