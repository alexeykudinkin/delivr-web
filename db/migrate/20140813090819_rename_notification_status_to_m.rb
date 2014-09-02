class RenameNotificationStatusToM < ActiveRecord::Migration
  def change
    rename_column :travel_notifications, :status, :message
  end
end
