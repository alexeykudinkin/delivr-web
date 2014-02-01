class CreateTravels < ActiveRecord::Migration
  def change
    create_table :travels do |t|
      t.string :origin
      t.string :destination

      t.timestamps
    end
  end
end
