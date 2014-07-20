class UnbindTravelsFromDestinations < ActiveRecord::Migration
  def change
    remove_column :travels, :destination_id
  end
end
