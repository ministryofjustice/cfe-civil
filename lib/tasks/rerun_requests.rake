namespace :rerun do
  desc "re-run request logs through v7 API and report differences"
  task requests: :environment do
    Rails.logger = Logger.new $stdout
    RequestRerunner.call
  end
end
