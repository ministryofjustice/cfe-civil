namespace :db do
  desc "batch job to redact client_id's in the request_log requests for payments"
  task redact: :environment do
    RedactClientIDService.call
  end
end
