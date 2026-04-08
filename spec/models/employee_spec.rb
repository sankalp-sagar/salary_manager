require 'rails_helper'

RSpec.describe Employee, type: :model do
  it "is valid with valid attributes" do
    employee = Employee.new(
      first_name: "John",
      last_name: "Titor",
      job_title: "Time Traveler",
      country: "USA",
      salary: 50000
    )

    expect(employee).to be_valid
  end
end
