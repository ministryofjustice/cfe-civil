# require "rails_helper"
# Dir[Rails.root.join("lib/integration_helpers/**/*.rb")].sort.each { |f| require f }
#
# ##### NOTE #####
# #
# # This spec can be run for just one worksheet, or with varying levels of verbosity with the
# # executable bin/ispec, for example:
# #
# #     bin/ispec -r -vv -w NPE6-1
# #
# # Will force a refresh of all the spreadsheets, process only worksheet NPE6-1, and have verbosity level 2
# # (show details of all payloads and responses)
# #
# #    bin/ispec -h # show help text

# RSpec.describe "IntegrationTests::TestRunner", :calls_bank_holiday, :vcr, type: :request do
#   let(:spreadsheet_title) { "CFE Integration Test V3" }
#   let(:target_worksheet) { ENV["TARGET_WORKSHEET"] }
#   let(:verbosity_level) { (ENV["VERBOSE"] || "0").to_i }
#   let(:refresh) { ENV["REFRESH"] || "false" }
#
#   let(:spreadsheet_file) { Rails.root.join("tmp/integration_test_data.xlsx") }
#   let(:spreadsheet) { Roo::Spreadsheet.open(spreadsheet_file.to_s) }
#   let(:worksheet_names) { spreadsheet.sheets }
#   let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json" } }
#
#   before { setup_test_data }
#
#   describe "run integration_tests" do
#     ispec_run = ENV["ISPEC_RUN"].present?
#
#     if ispec_run
#       it "processes all the tests on all the sheets" do
#         failing_tests = []
#         test_count = 0
#         group_runner = TestCase::GroupRunner.new(verbosity_level, refresh)
#         group_runner.each do |worksheet|
#           next if target_worksheet.nil? && worksheet.skippable?
#           next if target_worksheet.present? && target_worksheet != worksheet.worksheet_name
#
#           test_count += 1
#           puts ">>> RUNNING TEST #{worksheet.description} <<<".yellow unless silent?
#           pass = run_test_case(worksheet, verbosity_level)
#           failing_tests << worksheet.description unless pass
#           result_message(failing_tests, test_count) unless silent?
#         end
#         expect(failing_tests).to be_empty, "Failing tests: #{failing_tests.join(', ')}"
#       end
#     elsif ENV["GOOGLE_SHEETS_PRIVATE_KEY_ID"].present?
#       TestCase::GroupRunner.new(0, "false").each do |worksheet|
#         next if worksheet.skippable?
#
#         it "#{worksheet.description} passes" do
#           run_test_case(worksheet, 0)
#         end
#       end
#     end
#
#     def result_message(failing_tests, test_count)
#       if failing_tests.empty?
#         puts "#{test_count} tests run successfully".green
#       else
#         puts "#{failing_tests.size} tests failed out of #{test_count}".red
#         failing_tests.each { |t| puts " >> #{t}".red }
#       end
#     end
#
#     def run_test_case(worksheet, verbosity_level)
#       worksheet.parse_worksheet
#       payloads_hash = worksheet.payload_objects.reject(&:blank?).map { |obj| [obj.url_method, obj.payload] }.to_h
#       url_method_mapping = {
#         assessment_capitals_path: :capitals,
#         assessment_cash_transactions_path: :cash_transactions,
#         assessment_irregular_incomes_path: :irregular_incomes,
#       }
#       v6_payloads = payloads_hash.map do |url_method, payload|
#         if url_method_mapping.key? url_method
#           { url_method_mapping.fetch(url_method) => payload }
#         else
#           payload
#         end
#       end
#       single_shot_payload = v6_payloads.reduce(assessment: worksheet.assessment.attributes) { |hash, elem| hash.merge(elem) }
#       v6_api_results = noisy_post("/v6/assessments", single_shot_payload, worksheet.version)
#       TestCase::V5::ResultComparer.call(v6_api_results, worksheet.expected_results.result_set, verbosity_level).each do |item|
#         # avoid checking zero contributions
#         unless item.fetch(:name).ends_with?("contribution") && item.fetch(:expected).to_i == 0
#           expect(item.fetch(:actual)).to eq(item.fetch(:expected)), "Expected #{item.fetch(:name)} to be #{item.fetch(:expected)}, is #{item.fetch(:actual)}"
#         end
#       end
#     end
#
#     def noisy_post(url, payload, version)
#       puts ">>>>>>>>>>>> #{url} V#{version} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow unless silent?
#       pp payload if noisy?
#       post url, params: payload.to_json, headers: headers(version)
#       pp parsed_response if noisy?
#       puts " \n" if noisy?
#       raise "Unsuccessful response: #{parsed_response.inspect}" unless parsed_response[:success]
#
#       parsed_response
#     end
#
#     def post_assessment(worksheet)
#       url = worksheet.assessment.url
#       payload = worksheet.assessment.payload
#       noisy_post url, payload, worksheet.version
#       parsed_response[:assessment_id]
#     end
#
#     def silent?
#       verbosity_level == 0
#     end
#
#     def noisy?
#       verbosity_level == 2
#     end
#
#     def headers(version)
#       { "CONTENT_TYPE" => "application/json", "Accept" => "application/json;version=#{version}" }
#     end
#
#     def setup_test_data
#       Dibber::Seeder.new(StateBenefitType, "data/state_benefit_types.yml", name_method: :label, overwrite: true).build
#     end
#   end
# end
