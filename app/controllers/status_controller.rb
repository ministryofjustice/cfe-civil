class StatusController < ApplicationController
  def status
    checks = {
      database: database_alive?,
    }
    status = :bad_gateway unless checks.values.all?
    render status:, json: { checks: }
  end

  def ping
    render json: {
      "build_date" => Rails.configuration.x.status.build_date,
      "build_tag" => Rails.configuration.x.status.build_tag,
      "app_branch" => Rails.configuration.x.status.app_branch,
    }
  end

private

  def database_alive?
    ActiveRecord::Base.connection.active? && database_migrations_run?
  rescue PG::ConnectionBad, PG::UndefinedTable
    false
  end

  def database_migrations_run?
    table = RequestLog.table_name
    ActiveRecord::Base.connection.schema_cache.clear_data_source_cache!(table)
    ActiveRecord::Base.connection.table_exists?(table)
  end
end
