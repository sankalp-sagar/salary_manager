module Api
  module V1
    class AuthController < ApplicationController
      before_action :authenticate_request, only: :logout

      def login
        user = User.find_by(email: params[:email].to_s.downcase)

        if user&.authenticate(params[:password])
          issue_tokens_for(user)
        else
          render_unauthorized("Invalid credentials")
        end
      end

      def refresh
        existing_token = RefreshToken.find_active_by_plain_token(params[:refresh_token])
        return render_unauthorized("Invalid refresh token") unless existing_token

        user = existing_token.user
        new_refresh_record, new_refresh_token = RefreshToken.issue_for!(user)
        existing_token.revoke!(replaced_by: new_refresh_record)

        render json: {
          access_token: JsonWebToken.encode(user_id: user.id, role: user.role),
          refresh_token: new_refresh_token
        }, status: :ok
      end

      def logout
        refresh_token = params[:refresh_token]
        if refresh_token.present?
          token_record = current_user.refresh_tokens.find_by(token_digest: RefreshToken.digest(refresh_token))
          token_record&.revoke!
        end

        head :no_content
      end

      private

      def issue_tokens_for(user)
        _record, refresh_token = RefreshToken.issue_for!(user)
        render json: {
          access_token: JsonWebToken.encode(user_id: user.id, role: user.role),
          refresh_token: refresh_token
        }, status: :ok
      end
    end
  end
end
