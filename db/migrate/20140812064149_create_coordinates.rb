class CreateCoordinates < ActiveRecord::Migration
  def change
    create_table :coordinates, id: false do |t|
      t.integer :user_id, null: false
      t.float :latitude, null: false
      t.float :longitude, null: false

      t.timestamps
    end

    add_index :coordinates, :user_id, unique: true
    add_index :coordinates, [:updated_at]

  end
end
