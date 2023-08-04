namespace :maintenance do
  desc "run all maintenance tasks"
  task tasks: :environment do
    CullStaleAssessmentsService.call
    RedactService.redact_old_client_refs
  end
end
