class Employee < ApplicationRecord
  validates :first_name, :last_name, :job_title, :country, :salary, presence: true
  validates :salary, numericality: { greater_than: 0 }
  validates :joining_date, presence: true
  validate :left_at_after_joining_date

  scope :active, -> { where(left_at: nil) }
  scope :former, -> { where.not(left_at: nil) }

  def active?
    left_at.nil?
  end

  def tenure_in_days
    return unless joining_date

    (left_at || Date.current) - joining_date
  end

  private

  def left_at_after_joining_date
    return if left_at.blank? || joining_date.blank?

    if left_at < joining_date
      errors.add(:left_at, "must be after joining date")
    end
  end
end
