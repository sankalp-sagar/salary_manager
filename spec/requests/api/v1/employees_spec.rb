require 'rails_helper'

RSpec.describe "Employees API", type: :request do
  describe "POST /api/v1/employees" do
    it "creates an employee" do
      post "/api/v1/employees", params: {
        employee: {
          first_name: "John",
          last_name: "Titor",
          job_title: "Time Traveler",
          country: "USA",
          salary: 50000
        }
      }

      expect(response).to have_http_status(:created)
    end

    it "creates an employee in database" do
      expect {
        post "/api/v1/employees", params: {
          employee: {
            first_name: "John",
            last_name: "Titor",
            job_title: "Time Traveler",
            country: "USA",
            salary: 50000
          }
        }
      }.to change(Employee, :count).by(1)
    end

    it "returns a list of employees" do
      Employee.create!(
        first_name: "Amitabh",
        last_name: "Bacchan",
        job_title: "Actor",
        country: "India",
        salary: 70000
      )

      get "/api/v1/employees"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to be > 0
    end
  end
end
