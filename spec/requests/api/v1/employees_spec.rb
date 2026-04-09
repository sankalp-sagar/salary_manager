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

  describe "GET /api/v1/employees/:id" do
    let!(:employee_record) do
      Employee.create!(
        first_name: "Jane",
        last_name: "Smith",
        job_title: "Engineer",
        country: "UK",
        salary: 60000,
        joining_date: Date.today
      )
    end

    it "blocks unauthenticated access" do
      get "/api/v1/employees/#{employee_record.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it "blocks employee role" do
      get "/api/v1/employees/#{employee_record.id}",
          headers: { "Authorization" => "Bearer #{emp_token}" }

      expect(response).to have_http_status(:forbidden)
    end

    it "returns 404 when employee does not exist" do
      get "/api/v1/employees/999_999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns the employee" do
      get "/api/v1/employees/#{employee_record.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.dig("data", "id")).to eq(employee_record.id)
      expect(json.dig("data", "first_name")).to eq("Jane")
    end
  end

  describe "PATCH /api/v1/employees/:id" do
    let!(:employee_record) do
      Employee.create!(
        first_name: "Pat",
        last_name: "Lee",
        job_title: "Analyst",
        country: "Canada",
        salary: 55000,
        joining_date: Date.today
      )
    end

    it "blocks unauthenticated access" do
      patch "/api/v1/employees/#{employee_record.id}",
            params: { employee: { salary: 60_000 } }
      expect(response).to have_http_status(:unauthorized)
    end

    it "blocks employee role" do
      patch "/api/v1/employees/#{employee_record.id}",
            params: { employee: { salary: 60_000 } },
            headers: { "Authorization" => "Bearer #{emp_token}" }

      expect(response).to have_http_status(:forbidden)
    end

    it "returns 404 when employee does not exist" do
      patch "/api/v1/employees/999_999",
            params: { employee: { salary: 60_000 } },
            headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns validation errors for invalid data" do
      patch "/api/v1/employees/#{employee_record.id}",
            params: { employee: { salary: -1 } },
            headers: auth_headers

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "updates the employee" do
      patch "/api/v1/employees/#{employee_record.id}",
            params: { employee: { salary: 72_000, job_title: "Senior Analyst" } },
            headers: auth_headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.dig("data", "salary")).to eq(72_000)
      expect(json.dig("data", "job_title")).to eq("Senior Analyst")
    end
  end

  describe "DELETE /api/v1/employees/:id" do
    let!(:employee_record) do
      Employee.create!(
        first_name: "Del",
        last_name: "Me",
        job_title: "Temp",
        country: "USA",
        salary: 40000,
        joining_date: Date.today
      )
    end

    it "blocks unauthenticated access" do
      delete "/api/v1/employees/#{employee_record.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it "blocks employee role" do
      delete "/api/v1/employees/#{employee_record.id}",
             headers: { "Authorization" => "Bearer #{emp_token}" }

      expect(response).to have_http_status(:forbidden)
    end

    it "returns 404 when employee does not exist" do
      delete "/api/v1/employees/999_999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it "deletes the employee" do
      expect {
        delete "/api/v1/employees/#{employee_record.id}", headers: auth_headers
      }.to change(Employee, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
