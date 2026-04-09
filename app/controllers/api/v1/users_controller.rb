module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_request
      before_action :authorize_admin!

      def create
        user = User.new(user_params)

        if user.save
          render json: { data: user }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_content
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
    end
  end
end
