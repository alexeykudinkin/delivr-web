class CreateAdopters < ActiveRecord::Migration
  def change
    create_table :adopters do |t|
      t.string  :email

      t.timestamps
    end
  end
end
