module Api
  module V1
    class SalaryInsightsController < ApplicationController
      before_action :authenticate_request
      before_action :authorize_hr!

      def by_country
        rows = Employee.where.not(country: nil)
                         .where.not(country: "")
                         .group(:country)
                         .order(:country)
                         .pluck(
                           Arel.sql("country"),
                           Arel.sql("COUNT(*)::integer"),
                           Arel.sql("MIN(salary)"),
                           Arel.sql("MAX(salary)"),
                           Arel.sql("AVG(salary)")
                         )

        data = rows.map do |country, count, min_salary, max_salary, avg_salary|
          {
            country: country,
            employee_count: count,
            min_salary: min_salary,
            max_salary: max_salary,
            avg_salary: avg_salary.to_f.round(2)
          }
        end

        render json: { data: data }
      end
    end
  end
end
