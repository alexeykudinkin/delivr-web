class AddAccessTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.integer :owner_id,   null: false, unique: true
      t.string  :owner_type, null: false

      t.string  :value, null: false, unique: true
      t.timestamps
    end
  end
end
