class BindItemsToDestinations < ActiveRecord::Migration
  def change
    add_column :items, :destination_id, :integer # :null => false
  end
end
