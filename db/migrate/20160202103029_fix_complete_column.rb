class FixCompleteColumn < ActiveRecord::Migration
  def change
    change_column :todos, :complete, :boolean, null: false, default: false
  end
end
