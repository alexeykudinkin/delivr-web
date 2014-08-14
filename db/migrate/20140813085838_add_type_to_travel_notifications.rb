class AddTypeToTravelNotifications < ActiveRecord::Migration
  def change
    add_column :travel_notifications, :type, :string
  end
end
