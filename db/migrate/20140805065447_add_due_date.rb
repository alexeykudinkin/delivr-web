class AddDueDate < ActiveRecord::Migration
  def change
    drop_table :due_dates if table_exists? :due_dates

    create_table :due_dates do |t|
      t.datetime :starts,   null: false
      t.datetime :ends,     null: false

      t.integer :destination_id, null: false
    end
  end
end
