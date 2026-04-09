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

      def by_job_title_in_country
        country_param = params[:country].to_s.strip
        return render_bad_request("country is required") if country_param.blank?

        scope = Employee.where(country: country_param)
                         .where.not(job_title: nil)
                         .where.not(job_title: "")

        job_title_filter = params[:job_title].to_s.strip
        scope = scope.where(job_title: job_title_filter) if job_title_filter.present?

        rows = scope.group(:job_title)
                     .order(:job_title)
                     .pluck(
                       Arel.sql("job_title"),
                       Arel.sql("COUNT(*)::integer"),
                       Arel.sql("MIN(salary)"),
                       Arel.sql("MAX(salary)"),
                       Arel.sql("AVG(salary)")
                     )

        data = rows.map do |job_title, count, min_salary, max_salary, avg_salary|
          {
            country: country_param,
            job_title: job_title,
            employee_count: count,
            min_salary: min_salary,
            max_salary: max_salary,
            avg_salary: avg_salary.to_f.round(2)
          }
        end

        render json: { data: data }
      end

      def employment_by_country
        rows = Employee.where.not(country: nil)
                         .where.not(country: "")
                         .group(:country)
                         .order(:country)
                         .pluck(
                           Arel.sql("country"),
                           Arel.sql("COUNT(*) FILTER (WHERE left_at IS NULL)::integer"),
                           Arel.sql("COUNT(*) FILTER (WHERE left_at IS NOT NULL)::integer"),
                           Arel.sql("AVG(salary) FILTER (WHERE left_at IS NULL)"),
                           Arel.sql("AVG(salary) FILTER (WHERE left_at IS NOT NULL)")
                         )

        data = rows.map do |country, active_count, former_count, active_avg, former_avg|
          {
            country: country,
            active_count: active_count,
            former_count: former_count,
            active_avg_salary: round_avg_salary(active_avg),
            former_avg_salary: round_avg_salary(former_avg)
          }
        end

        render json: { data: data }
      end

      def top_job_titles
        limit = parse_top_limit(params[:limit])

        rows = Employee.where.not(job_title: nil)
                         .where.not(job_title: "")
                         .group(:job_title)
                         .order(Arel.sql("COUNT(*) DESC"), :job_title)
                         .limit(limit)
                         .pluck(
                           Arel.sql("job_title"),
                           Arel.sql("COUNT(*)::integer")
                         )

        data = rows.map do |job_title, count|
          { job_title: job_title, employee_count: count }
        end

        render json: { data: data, meta: { limit: limit } }
      end

      private

      def round_avg_salary(value)
        return nil if value.nil?

        value.to_f.round(2)
      end

      def parse_top_limit(raw)
        n = raw.to_s.strip.presence&.to_i
        n = 10 if n.nil? || n < 1
        [ n, 50 ].min
      end
    end
  end
end
