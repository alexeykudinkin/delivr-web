class CreateTravels < ActiveRecord::Migration
  def change
    create_table :travels do |t|
      t.string :origin_address
      t.string :origin_coordinates

      t.string :destination_address
      t.string :destination_coordinates

      t.timestamps
    end
  end
end
