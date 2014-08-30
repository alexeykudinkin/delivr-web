class AddStateToUsers < ActiveRecord::Migration
  def change
    create_table :user_states do |t|
      t.integer :user_id, null: false, unique: true

      t.string  :status, null: false

      t.timestamps
    end
  end
end
