class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :address
      t.string :coordinates

      t.timestamps
    end
  end
end
