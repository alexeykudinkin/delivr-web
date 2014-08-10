class AddDueDate < ActiveRecord::Migration
  def change
    create_table :due_dates do |t|
      t.date :starts,   null: false
      t.date :ends,     null: false

      t.integer :destination_id, null: false
    end
  end
end
