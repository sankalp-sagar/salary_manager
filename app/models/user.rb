class User < ApplicationRecord
  has_secure_password

  enum :role, { employee: 0, hr_manager: 1, admin: 2 }

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
