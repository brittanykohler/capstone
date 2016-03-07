class ChangeOffsetToInt < ActiveRecord::Migration
  def change
    change_column :users, :offset_from_utc_millis, :integer
  end
end
