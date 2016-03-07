class AddOffsetFromUtc < ActiveRecord::Migration
  def change
    add_column :users, :offset_from_utc_millis, :integer
  end
end
