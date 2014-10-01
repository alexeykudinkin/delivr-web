class ExtendRoutePolylineLimit < ActiveRecord::Migration
  def change
    change_column :routes, :polyline, :text, limit: 4096
  end
end
