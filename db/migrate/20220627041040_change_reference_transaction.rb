class ChangeReferenceTransaction < ActiveRecord::Migration[6.0]
  def change
    remove_reference :transactions, :user, index: true, foreign_key: true
    add_reference :transactions, :category, index: true, null: false, foreign_key: true
  end
end
