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
  end
end
