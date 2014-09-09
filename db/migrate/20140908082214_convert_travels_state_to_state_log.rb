class ConvertTravelsStateToStateLog < ActiveRecord::Migration
  def change
    drop_table :travel_states

    create_table :travels_states_log do |t|
      t.integer :travel_id, null: false

      t.string  :type   # STI

      t.timestamps
    end
  end
end
