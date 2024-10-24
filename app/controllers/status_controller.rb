class StatusController < ApplicationController
  def status
    checks = {
      database: database_healthy?,
      short_term_persistence: short_term_persistence_healthy?
    }
    status = :bad_gateway unless checks.values.all?
    render status:, json: { checks: }
  end

  def ping
    render json: { alive: true }
  end

  private

  def database_healthy?
    ActiveRecord::Base.connection.active?
    Assessment.count.is_a?(Numeric)
  rescue PG::ConnectionBad, PG::UndefinedTable
    false
  end

  def short_term_persistence_healthy?
    Rails.cache.write("_health_check_", "ok", expires_in: 5.seconds) &&
      Rails.cache.read("_health_check_") == "ok"
  rescue StandardError
    false
  end
end
