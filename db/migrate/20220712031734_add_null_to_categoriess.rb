class AddNullToCategoriess < ActiveRecord::Migration[6.0]
  def change
    change_column_null :categories, :user_id, true
  end
end
