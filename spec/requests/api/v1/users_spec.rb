require 'rails_helper'

RSpec.describe "Users API", type: :request do
  let!(:admin) do
    User.create!(
      email: "admin@test.com",
      password: "password",
      role: "admin"
    )
  end

  let(:admin_token) { JsonWebToken.encode(user_id: admin.id) }

  let(:valid_params) do
    {
      user: {
        email: "new@test.com",
        password: "password",
        role: "employee",
        first_name: "New",
        last_name: "User"
      }
    }
  end

  describe "POST /api/v1/users" do
    it "blocks unauthenticated request" do
      post "/api/v1/users", params: valid_params
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows admin to create user" do
      expect {
        post "/api/v1/users",
             params: valid_params,
             headers: { "Authorization" => "Bearer #{admin_token}" }
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json.dig("data", "password_digest")).to be_nil
    end

    it "blocks non-admin users" do
      hr = User.create!(
        email: "hr@test.com",
        password: "password",
        role: "hr_manager"
      )

      token = JsonWebToken.encode(user_id: hr.id)

      post "/api/v1/users",
           params: valid_params,
           headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:forbidden)
    end

    it "rejects expired token" do
      expired_token = JsonWebToken.encode({ user_id: admin.id }, expires_in: -1.second)
      post "/api/v1/users",
           params: valid_params,
           headers: { "Authorization" => "Bearer #{expired_token}" }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
