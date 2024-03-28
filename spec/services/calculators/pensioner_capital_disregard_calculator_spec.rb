require "rails_helper"

module Calculators
  RSpec.describe PensionerCapitalDisregardCalculator do
    let(:value) do
      if applicant.receives_qualifying_benefit
        described_class.passported_value(submission_date: assessment.submission_date,
                                         date_of_birth: applicant.date_of_birth)
      else
        described_class.non_passported_value(submission_date: assessment.submission_date,
                                             date_of_birth: applicant.date_of_birth,
                                             total_disposable_income: disposable_income)
      end
    end
    let(:assessment) { build :assessment }
    let(:disposable_income) { 0 }

    describe "#value" do
      context "non-passported" do
        context "not a pensioner" do
          let(:applicant) { build :applicant, :without_qualifying_benefits, :pensionable_age_under_60 }

          it "returns zero" do
            expect(value).to eq 0.0
          end
        end

        context "a pensioner" do
          context "non-passported" do
            let(:applicant) { build :applicant, :without_qualifying_benefits, :pensionable_age_over_60 }

            context "with an income of 0" do
              it "returns the maximum value" do
                expect(value).to eq 100_000.0
              end
            end

            context "with an income of -100" do
              let(:disposable_income) { -100.0 }

              it "returns the maximum value" do
                expect(value).to eq 100_000.0
              end
            end

            context "with an income of 50" do
              let(:disposable_income) { 50 }

              it "returns 90k" do
                expect(value).to eq 90_000.0
              end
            end

            context "with an income of 51" do
              let(:disposable_income) { 51.0 }

              it "returns 80k" do
                expect(value).to eq 80_000.0
              end
            end

            context "with an income of 76.0" do
              let(:disposable_income) { 76.0 }

              it "returns 70k" do
                expect(value).to eq 70_000.0
              end
            end

            context "with an income above the max threshold" do
              let(:disposable_income) { 316 }

              it "returns 0" do
                expect(value).to eq 0.0
              end
            end
          end
        end
      end

      context "passported" do
        let(:applicant) { build :applicant, :with_qualifying_benefits, :pensionable_age_over_60 }

        it "returns the passported value" do
          expect(value).to eq 100_000.0
        end
      end

      context "MTR - when threshold 'pensioner_capital_disregard.minimum_age_in_years = 'state_pension_age'" do
        around do |example|
          travel_to Date.new(2525, 4, 20)
          example.run
          travel_back
        end

        context "when applicant is pensioner(69 years old)" do
          let(:applicant) { build :applicant, :with_qualifying_benefits, date_of_birth: Date.parse("2456-04-20") }

          it "returns the passported value" do
            expect(value).to eq 100_000.0
          end
        end

        context "when applicant is not pensioner(67 years old)" do
          let(:applicant) { build :applicant, :with_qualifying_benefits, date_of_birth: Date.parse("2458-04-20") }

          it "returns the passported value" do
            expect(value).to eq 0
          end
        end
      end
    end
  end
end
