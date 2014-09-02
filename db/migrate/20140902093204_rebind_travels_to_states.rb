class RebindTravelsToStates < ActiveRecord::Migration
  def change
    add_column :travels, :state_id, :integer # null: false
  end
end