class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :u_id
      t.string :name
      t.string :stride_length_walking
      t.string :stride_length_running
      t.string :timezone
      t.string :photo
      t.string :city
      t.string :country

      t.timestamps null: false
    end
  end
end
