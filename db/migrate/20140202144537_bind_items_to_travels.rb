class BindItemsToTravels < ActiveRecord::Migration
  def change
    add_column :items, :travel_id, :integer
  end
end
