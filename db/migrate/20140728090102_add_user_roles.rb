class AddUserRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :type, unique: true # STI, singleton-emulation
    end

    add_column :users, :role_id, :integer
  end
end
