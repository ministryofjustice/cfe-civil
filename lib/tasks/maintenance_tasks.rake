namespace :maintenance do
  desc "run all maintenance tasks"
  task tasks: :environment do
    CullStaleAssessmentsService.call
    RedactService.redact_old_client_refs

    # Storing data indefinitely is a red flag in terms of information management
    RequestLog.created_before(5.years.ago.to_date).delete_all
  end
end
