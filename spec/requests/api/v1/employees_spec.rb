require 'rails_helper'

RSpec.describe "Employees API", type: :request do
  describe "POST /api/v1/employees" do
    let(:valid_params) do
      {
        employee: {
          first_name: "John",
          last_name: "Titor",
          job_title: "Time Traveler",
          country: "USA",
          salary: 50000,
          joining_date: Date.today
        }
      }
    end

    it "creates an employee" do
      post "/api/v1/employees", params: valid_params

      expect(response).to have_http_status(:created)
    end

    it "creates an employee in database" do
      expect {
        post "/api/v1/employees", params: valid_params
      }.to change(Employee, :count).by(1)
    end

    it "returns errors for invalid data" do
      post "/api/v1/employees", params: {
        employee: { first_name: "John" }
      }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /api/v1/employees" do
    before do
      Employee.create!(
        first_name: "Amitabh",
        last_name: "Bacchan",
        job_title: "Actor",
        country: "India",
        salary: 70000,
        joining_date: Date.today
      )
    end

    it "returns a list of employees" do
      get "/api/v1/employees"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to have_key("data")
      expect(json["data"].length).to be > 0
      expect(json).to have_key("meta")
    end

    it "returns paginated employees" do
      15.times do |i|
        Employee.create!(
          first_name: "John#{i}",
          last_name: "Doe",
          job_title: "Engineer",
          country: "USA",
          salary: 10000,
          joining_date: Date.today
        )
      end

      get "/api/v1/employees", params: { page: 1, per_page: 10 }

      json = JSON.parse(response.body)

      expect(json["data"].length).to eq(10)
      expect(json["meta"]["page"]).to eq(1)
      expect(json["meta"]["per_page"]).to eq(10)
    end
  end
end
