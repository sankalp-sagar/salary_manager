require 'rails_helper'

RSpec.describe "Auth API", type: :request do
  let!(:user) do
    User.create!(
      email: "admin@test.com",
      password: "password",
      role: "admin"
    )
  end

  describe "POST /api/v1/login" do
    it "returns access and refresh token for valid credentials" do
      post "/api/v1/login", params: {
        email: "admin@test.com",
        password: "password"
      }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to have_key("access_token")
      expect(json).to have_key("refresh_token")
    end

    it "returns unauthorized for invalid credentials" do
      post "/api/v1/login", params: {
        email: "admin@test.com",
        password: "wrong"
      }

      expect(response).to have_http_status(:unauthorized)
    end

    it "throttles repeated failed login attempts" do
      10.times do
        post "/api/v1/login", params: { email: "admin@test.com", password: "wrong" }
        expect(response).to have_http_status(:unauthorized)
      end

      post "/api/v1/login", params: { email: "admin@test.com", password: "wrong" }
      expect(response).to have_http_status(:too_many_requests)
    end
  end

  describe "POST /api/v1/refresh" do
    it "rotates refresh token and returns new token pair" do
      post "/api/v1/login", params: { email: "admin@test.com", password: "password" }
      login_json = JSON.parse(response.body)

      post "/api/v1/refresh", params: { refresh_token: login_json["refresh_token"] }
      expect(response).to have_http_status(:ok)

      refresh_json = JSON.parse(response.body)
      expect(refresh_json["access_token"]).to be_present
      expect(refresh_json["refresh_token"]).to be_present
      expect(refresh_json["refresh_token"]).not_to eq(login_json["refresh_token"])
    end

    it "rejects invalid refresh token" do
      post "/api/v1/refresh", params: { refresh_token: "invalid-token" }

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eq("Invalid refresh token")
    end

    it "rejects a rotated refresh token reuse" do
      post "/api/v1/login", params: { email: "admin@test.com", password: "password" }
      original_refresh = JSON.parse(response.body)["refresh_token"]

      post "/api/v1/refresh", params: { refresh_token: original_refresh }
      expect(response).to have_http_status(:ok)

      post "/api/v1/refresh", params: { refresh_token: original_refresh }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/logout" do
    it "revokes refresh token and returns no content" do
      post "/api/v1/login", params: { email: "admin@test.com", password: "password" }
      json = JSON.parse(response.body)

      delete "/api/v1/logout",
             params: { refresh_token: json["refresh_token"] },
             headers: { "Authorization" => "Bearer #{json["access_token"]}" }

      expect(response).to have_http_status(:no_content)
    end
  end
end
