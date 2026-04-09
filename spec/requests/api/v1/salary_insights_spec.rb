require "rails_helper"

RSpec.describe "Salary Insights API", type: :request do
  let(:hr) do
    User.create!(
      email: "hr-insights@test.com",
      password: "password",
      role: "hr_manager"
    )
  end

  let(:employee_user) do
    User.create!(
      email: "emp-insights@test.com",
      password: "password",
      role: "employee"
    )
  end

  let(:hr_token) { JsonWebToken.encode(user_id: hr.id) }
  let(:emp_token) { JsonWebToken.encode(user_id: employee_user.id) }

  let(:auth_headers) do
    { "Authorization" => "Bearer #{hr_token}" }
  end

  describe "GET /api/v1/salary_insights/by_country" do
    it "blocks unauthenticated request" do
      get "/api/v1/salary_insights/by_country"
      expect(response).to have_http_status(:unauthorized)
    end

    it "blocks employee role" do
      get "/api/v1/salary_insights/by_country",
          headers: { "Authorization" => "Bearer #{emp_token}" }

      expect(response).to have_http_status(:forbidden)
    end

    it "returns empty data when there are no employees" do
      get "/api/v1/salary_insights/by_country", headers: auth_headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]).to eq([])
    end

    it "returns min, max, and average salary grouped by country" do
      Employee.create!(
        first_name: "A",
        last_name: "One",
        job_title: "Engineer",
        country: "India",
        salary: 30_000,
        joining_date: Date.today
      )
      Employee.create!(
        first_name: "B",
        last_name: "Two",
        job_title: "Engineer",
        country: "India",
        salary: 60_000,
        joining_date: Date.today
      )
      Employee.create!(
        first_name: "C",
        last_name: "Three",
        job_title: "Manager",
        country: "USA",
        salary: 100_000,
        joining_date: Date.today
      )

      get "/api/v1/salary_insights/by_country", headers: auth_headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      data = json["data"]
      countries = data.map { |r| r["country"] }.sort
      expect(countries).to eq([ "India", "USA" ])

      india = data.find { |r| r["country"] == "India" }
      usa = data.find { |r| r["country"] == "USA" }

      expect(india["employee_count"]).to eq(2)
      expect(india["min_salary"]).to eq(30_000)
      expect(india["max_salary"]).to eq(60_000)
      expect(india["avg_salary"]).to eq(45_000.0)

      expect(usa["employee_count"]).to eq(1)
      expect(usa["min_salary"]).to eq(100_000)
      expect(usa["max_salary"]).to eq(100_000)
      expect(usa["avg_salary"]).to eq(100_000.0)
    end
  end
end
