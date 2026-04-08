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

  it "is invalid without salary" do
    employee = Employee.new(
      first_name: "John",
      last_name: "Titor",
      job_title: "Time Traveler",
      country: "USA"
    )

    expect(employee).not_to be_valid
  end

  it "is invalid with negative salary" do
    employee = Employee.new(
      first_name: "John",
      last_name: "Titor",
      job_title: "Time Traveler",
      country: "USA",
      salary: -100
    )

    expect(employee).not_to be_valid
  end
end
