module Api
  module V1
    class EmployeesController < ApplicationController
      before_action :authenticate_request
      before_action :authorize_hr!

      def index
        page = params[:page].to_i > 0 ? params[:page].to_i : 1
        per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 10

        employees = Employee.order(:id)
                            .offset((page - 1) * per_page)
                            .limit(per_page)

        render json: {
          data: employees.map { |employee| employee_payload(employee) },
          meta: {
            page: page,
            per_page: per_page,
            total: Employee.count
          }
        }
      end

      def create
        employee = Employee.new(employee_params)

        if employee.save
          render json: { data: employee_payload(employee) }, status: :created
        else
          render_unprocessable(employee.errors.full_messages)
        end
      end

      private

      def employee_params
        params.require(:employee).permit(
          :first_name,
          :last_name,
          :job_title,
          :country,
          :salary,
          :joining_date,
          :left_at
        )
      end

      def employee_payload(employee)
        employee.as_json(
          only: [
            :id,
            :first_name,
            :last_name,
            :job_title,
            :country,
            :salary,
            :joining_date,
            :left_at,
            :created_at,
            :updated_at
          ]
        )
      end
    end
  end
end
