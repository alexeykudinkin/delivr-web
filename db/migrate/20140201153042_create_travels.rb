class CreateTravels < ActiveRecord::Migration
  def change
    create_table :travels do |t|
      t.integer :origin_id
      t.integer :destination_id

      t.timestamps
    end
  end
end
