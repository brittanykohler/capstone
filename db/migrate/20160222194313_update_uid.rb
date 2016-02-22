class UpdateUid < ActiveRecord::Migration
  def change
    change_column :users, :u_id, :string
  end
end
