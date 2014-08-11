class AddDueDate < ActiveRecord::Migration
  def change
    create_table :due_dates do |t|
      t.datetime :starts,   null: false
      t.datetime :ends,     null: false

      t.integer :destination_id, null: false
    end
  end
end
