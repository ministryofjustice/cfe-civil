namespace :maintenance do
  desc "run all maintenance tasks"
  task tasks: :environment do
    CullStaleAssessmentsService.call
    RedactService.redact_old_client_refs
    RequestLog.created_before(5.years.ago.to_date).delete_all
  end
end
