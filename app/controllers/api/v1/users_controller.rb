module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_request
      before_action :authorize_admin!

      def create
        user = User.new(user_params)

        if user.save
          render json: { data: user_payload(user) }, status: :created
        else
          render_unprocessable(user.errors.full_messages)
        end
      end

      private

      def user_params
        params.require(:user).permit(
          :email,
          :password,
          :role,
          :first_name,
          :last_name
        )
      end

      def user_payload(user)
        user.as_json(
          only: [ :id, :email, :first_name, :last_name, :role, :created_at, :updated_at ]
        )
      end
    end
  end
end
