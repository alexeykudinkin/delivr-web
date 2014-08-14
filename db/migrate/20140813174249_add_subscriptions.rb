class AddSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :subscriber_id,   null: false, unique: true
      t.string  :subscriber_type, null: false

      t.string  :rid
      t.string  :type # STI
    end
  end
end
