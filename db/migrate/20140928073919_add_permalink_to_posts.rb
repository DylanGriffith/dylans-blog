class AddPermalinkToPosts < ActiveRecord::Migration
  def change
    change_table(:posts) do |t|
      t.text :permalink
    end
  end
end
