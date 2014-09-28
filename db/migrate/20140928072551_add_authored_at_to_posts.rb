class AddAuthoredAtToPosts < ActiveRecord::Migration
  def change
    change_table(:posts) do |t|
      t.timestamp :authored_at
    end
  end
end
