require 'rails_helper'

RSpec.describe Employee, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      employee = Employee.new(
        first_name: "John",
        last_name: "Titor",
        job_title: "Time Traveler",
        country: "USA",
        salary: 50000,
        joining_date: Date.today
      )

      expect(employee).to be_valid
    end

    it "is invalid without salary" do
      employee = Employee.new(
        first_name: "John",
        last_name: "Titor",
        job_title: "Time Traveler",
        country: "USA",
        joining_date: Date.today
      )

      expect(employee).not_to be_valid
    end

    it "is invalid with negative salary" do
      employee = Employee.new(
        first_name: "John",
        last_name: "Titor",
        job_title: "Time Traveler",
        country: "USA",
        salary: -100,
        joining_date: Date.today
      )

      expect(employee).not_to be_valid
    end

    it "is invalid without joining_date" do
      employee = Employee.new(
        first_name: "John",
        last_name: "Titor",
        job_title: "Time Traveler",
        country: "USA",
        salary: 50000,
        joining_date: nil
      )

      expect(employee).not_to be_valid
    end

    it "is invalid if left_at is before joining_date" do
      employee = Employee.new(
        first_name: "John",
        last_name: "Titor",
        job_title: "Time Traveler",
        country: "USA",
        salary: 50000,
        joining_date: Date.today,
        left_at: Date.yesterday
      )

      expect(employee).not_to be_valid
      expect(employee.errors[:left_at]).to include("must be after joining date")
    end
  end

  describe "#active?" do
    it "returns true if left_at is nil" do
      employee = Employee.new(joining_date: Date.today, left_at: nil)
      expect(employee.active?).to be true
    end

    it "returns false if left_at is present" do
      employee = Employee.new(joining_date: Date.today, left_at: Date.today)
      expect(employee.active?).to be false
    end
  end

  describe "#tenure_in_days" do
    it "calculates tenure for active employee" do
      employee = Employee.new(joining_date: 10.days.ago)
      expect(employee.tenure_in_days).to be >= 10
    end

    it "calculates tenure until left_at for former employee" do
      employee = Employee.new(
        joining_date: 10.days.ago,
        left_at: 5.days.ago
      )

      expect(employee.tenure_in_days).to eq(5)
    end
  end
end
