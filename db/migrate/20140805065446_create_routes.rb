class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.integer :travel_id, null: false, unique: true

      t.integer :cost,      null: false
      t.integer :duration,  null: false
      t.integer :length,    null: false

      t.string  :order,     null: false
      t.string  :polyline,  null: false
    end
  end
end
