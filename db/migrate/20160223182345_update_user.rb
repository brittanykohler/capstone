class UpdateUser < ActiveRecord::Migration
  def change
    add_column :users, :user_token, :string
    add_column :users, :user_secret, :string
  end
end
