class BindTravelsToCustomers < ActiveRecord::Migration
  def change
    add_column :travels, :customer_id, :integer
  end
end
