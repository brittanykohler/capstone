class FixOffsetFromUtc < ActiveRecord::Migration
  def change
    change_column :users, :offset_from_utc_millis, :string
  end
end
