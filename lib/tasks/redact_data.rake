namespace :db do
  desc "batch job to redact client_id's in the request_log requests for payments"
  task redact_data: :environment do
    RedactService.call
  end
end
