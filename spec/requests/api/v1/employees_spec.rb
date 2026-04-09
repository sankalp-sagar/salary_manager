require 'rails_helper'

RSpec.describe "Employees API", type: :request do
  let(:hr) do
    User.create!(
      email: "hr@test.com",
      password: "password",
      role: "hr_manager"
    )
  end

  let(:employee_user) do
    User.create!(
      email: "emp@test.com",
      password: "password",
      role: "employee"
    )
  end

  let(:hr_token) { JsonWebToken.encode(user_id: hr.id) }
  let(:emp_token) { JsonWebToken.encode(user_id: employee_user.id) }

  let(:auth_headers) do
    { "Authorization" => "Bearer #{hr_token}" }
  end

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

    it "blocks unauthenticated request" do
      post "/api/v1/employees", params: valid_params
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows hr_manager to create employee" do
      post "/api/v1/employees", params: valid_params, headers: auth_headers
      expect(response).to have_http_status(:created)
    end

    it "creates employee in database" do
      expect {
        post "/api/v1/employees", params: valid_params, headers: auth_headers
      }.to change(Employee, :count).by(1)
    end

    it "blocks employee role" do
      post "/api/v1/employees",
           params: valid_params,
           headers: { "Authorization" => "Bearer #{emp_token}" }

      expect(response).to have_http_status(:forbidden)
    end

    it "returns errors for invalid data" do
      post "/api/v1/employees",
           params: { employee: { first_name: "John" } },
           headers: auth_headers

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

    it "blocks unauthenticated access" do
      get "/api/v1/employees"
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows hr_manager" do
      get "/api/v1/employees", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it "blocks employee role" do
      get "/api/v1/employees",
          headers: { "Authorization" => "Bearer #{emp_token}" }

      expect(response).to have_http_status(:forbidden)
    end

    it "rejects expired token" do
      expired = JsonWebToken.encode({ user_id: hr.id }, expires_in: -1.second)
      get "/api/v1/employees", headers: { "Authorization" => "Bearer #{expired}" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns employee list with meta" do
      get "/api/v1/employees", headers: auth_headers

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

      get "/api/v1/employees",
          params: { page: 1, per_page: 10 },
          headers: auth_headers

      json = JSON.parse(response.body)

      expect(json["data"].length).to eq(10)
      expect(json["meta"]["page"]).to eq(1)
      expect(json["meta"]["per_page"]).to eq(10)
    end
  end
end
