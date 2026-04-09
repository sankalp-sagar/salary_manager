class AddEmploymentDatesToEmployees < ActiveRecord::Migration[8.1]
  def change
    add_column :employees, :joining_date, :date, null: false
    add_column :employees, :left_at, :date
    add_index :employees, :joining_date
    add_index :employees, :left_at
  end
end
