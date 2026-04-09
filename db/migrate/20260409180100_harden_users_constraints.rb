class HardenUsersConstraints < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :email, false
    change_column_null :users, :password_digest, false
    change_column_null :users, :role, false

    add_index :users, :email, unique: true
  end
end
