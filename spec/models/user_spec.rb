require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      user = User.new(
        email: "admin@test.com",
        password: "password",
        role: "admin",
        first_name: "Admin",
        last_name: "User"
      )

      expect(user).to be_valid
    end

    it "is invalid without email" do
      user = User.new(password: "password", role: "admin")
      expect(user).not_to be_valid
    end

    it "is invalid with duplicate email" do
      User.create!(
        email: "test@test.com",
        password: "password",
        role: "admin"
      )

      user = User.new(
        email: "test@test.com",
        password: "password",
        role: "employee"
      )

      expect(user).not_to be_valid
    end

    it "is invalid without password on create" do
      user = User.new(email: "a@test.com", role: "admin")
      expect(user).not_to be_valid
    end
  end

  describe "roles" do
    it "supports admin role" do
      user = User.new(email: "a@test.com", password: "pass", role: "admin")
      expect(user.admin?).to be true
    end

    it "supports hr_manager role" do
      user = User.new(email: "a@test.com", password: "pass", role: "hr_manager")
      expect(user.hr_manager?).to be true
    end

    it "supports employee role" do
      user = User.new(email: "a@test.com", password: "pass", role: "employee")
      expect(user.employee?).to be true
    end
  end

  describe "#full_name" do
    it "returns full name" do
      user = User.new(first_name: "John", last_name: "Doe")
      expect(user.full_name).to eq("John Doe")
    end
  end
end
