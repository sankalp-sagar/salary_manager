class User < ApplicationRecord
  has_secure_password
  has_many :refresh_tokens, dependent: :destroy

  enum :role, { employee: 0, hr_manager: 1, admin: 2 }

  before_validation :normalize_email

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create

  def full_name
    "#{first_name} #{last_name}".strip
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
