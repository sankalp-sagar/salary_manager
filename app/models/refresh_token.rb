require "digest"

class RefreshToken < ApplicationRecord
  belongs_to :user

  before_validation :set_token_digest, on: :create

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

  attr_reader :plain_token

  def self.issue_for!(user, ttl: 30.days)
    token = SecureRandom.hex(64)
    record = create!(
      user: user,
      token_digest: digest(token),
      expires_at: Time.current + ttl
    )
    [record, token]
  end

  def self.find_active_by_plain_token(token)
    return nil if token.blank?

    active.find_by(token_digest: digest(token))
  end

  def revoke!(replaced_by: nil)
    update!(revoked_at: Time.current, replaced_by_token_id: replaced_by&.id)
  end

  def active?
    revoked_at.nil? && expires_at.future?
  end

  def self.digest(token)
    Digest::SHA256.hexdigest(token.to_s)
  end

  private

  def set_token_digest
    return unless token_digest.blank?

    self.plain_token = SecureRandom.hex(64)
    self.token_digest = self.class.digest(plain_token)
  end

  attr_writer :plain_token
end
