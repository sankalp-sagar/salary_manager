class CreateRefreshTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :refresh_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.bigint :replaced_by_token_id

      t.timestamps
    end

    add_index :refresh_tokens, :token_digest, unique: true
    add_index :refresh_tokens, :expires_at
    add_index :refresh_tokens, :revoked_at
    add_index :refresh_tokens, :replaced_by_token_id
  end
end
