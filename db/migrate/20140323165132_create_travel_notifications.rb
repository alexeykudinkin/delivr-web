class CreateTravelNotifications < ActiveRecord::Migration
  def change
    create_table :travel_notifications do |t|
      t.integer :travel_id

      t.string  :status

      t.boolean :read # signals actuality of this notification

      t.timestamps
    end
  end
end
