class BindTravelsToPerformers < ActiveRecord::Migration
  def change
    add_column :travels, :performer_id, :integer
  end
end
