class AddTypeToCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :type_name, :integer, default: 0
  end
end
