class AddStates < ActiveRecord::Migration

  def change
    create_table :states do |t|
      t.integer :travel_id

      t.boolean :taken,     default: false, null: false
      t.boolean :completed, default: false, null: false
      t.boolean :withdrawn, default: false, null: false
    end
  end

end
