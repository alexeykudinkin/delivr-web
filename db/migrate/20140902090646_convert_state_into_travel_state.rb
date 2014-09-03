class ConvertStateIntoTravelState < ActiveRecord::Migration
  def change
    drop_table :states

    create_table :travel_states do |t|
      t.string :status, null: false, unique: true
    end

  end
end
