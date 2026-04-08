class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.string :job_title
      t.string :country
      t.integer :salary

      t.timestamps
    end
  end
end
