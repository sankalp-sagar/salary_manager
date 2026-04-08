class Employee < ApplicationRecord
  validates :first_name, :last_name, :job_title, :country, :salary, presence: true
end
