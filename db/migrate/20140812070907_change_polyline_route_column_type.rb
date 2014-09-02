class ChangePolylineRouteColumnType < ActiveRecord::Migration
  def change
    change_column :routes, :polyline, :text, null: false
  end
end
