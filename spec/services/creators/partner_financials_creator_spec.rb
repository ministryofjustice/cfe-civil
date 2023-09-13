require "rails_helper"

module Creators
  RSpec.describe PartnerFinancialsCreator do
    let(:assessment) { create :assessment }
    let(:assessment_id) { assessment.id }
    let(:date_of_birth) { Faker::Date.backward.to_s }
    let(:partner_financials_params) do
      {
        partner: {
          date_of_birth:,
          employed: true,
        },
      }
    end

    subject(:creator) { described_class.call(assessment:, partner_financials_params:) }

    describe ".call" do
      context "with valid basic partner payload" do
        it "returns a success status flag" do
          expect(creator.success?).to be true
        end

        it "returns an empty error array" do
          expect(creator.errors).to be_empty
        end
      end

      context "with valid irregular income" do
        let(:partner_financials_params) do
          {
            partner: {
              date_of_birth:,
              employed: true,
            },
            irregular_incomes: [
              {
                income_type: "unspecified_source",
                frequency: "monthly",
                amount: 101.01,
              },
            ],
          }
        end

        it "returns a success status flag" do
          expect(creator.success?).to be true
        end

        it "creates an income object" do
          creator
          expect(assessment.partner_gross_income_summary.irregular_income_payments.count).to eq 1
        end
      end

      context "with valid employment" do
        let(:partner_financials_params) do
          {
            partner: {
              date_of_birth:,
              employed: true,
            },
            employments: [
              {
                name: "Job 1",
                client_id: "employment-id-1",
                payments: [
                  {
                    client_id: "employment-1-payment-1",
                    date: "2021-10-30",
                    gross: 1046.00,
                    benefits_in_kind: 16.60,
                    tax: -104.10,
                    national_insurance: -18.66,
                  },
                  {
                    client_id: "employment-1-payment-2",
                    date: "2021-10-30",
                    gross: 1046.00,
                    benefits_in_kind: 16.60,
                    tax: -104.10,
                    national_insurance: -18.66,
                  },
                  {
                    client_id: "employment-1-payment-3",
                    date: "2021-10-30",
                    gross: 1046.00,
                    benefits_in_kind: 16.60,
                    tax: -104.10,
                    national_insurance: -18.66,
                  },
                ],
              },
            ],
          }
        end

        it "returns a success status flag" do
          expect(creator.success?).to be true
        end
      end

      context "with valid regular transactions" do
        let(:partner_financials_params) do
          {
            partner: {
              date_of_birth:,
              employed: true,
            },
            regular_transactions: [
              {
                category: "benefits",
                operation: "credit",
                amount: 9.99,
                frequency: "monthly",
              },
            ],
          }
        end

        it "returns a success status flag" do
          expect(creator.success?).to be true
        end

        it "creates a transaction object" do
          creator
          expect(assessment.partner_gross_income_summary.regular_transactions.count).to eq 1
        end
      end

      context "with valid state benefits" do
        let(:state_benefit_type) { create :state_benefit_type }
        let(:partner_financials_params) do
          {
            partner: {
              date_of_birth:,
              employed: true,
            },
            state_benefits: [
              {
                name: state_benefit_type.label,
                payments: [
                  { date: 3.days.ago.to_date.to_s, amount: 266.95, client_id: "abc123" },
                ],
              },
            ],
          }
        end

        it "returns a success status flag" do
          expect(creator.success?).to be true
        end

        it "creates a benefit object" do
          creator
          expect(assessment.partner_gross_income_summary.state_benefits.count).to eq 1
        end
      end

      context "with valid properties" do
        let(:partner_financials_params) do
          {
            partner: {
              date_of_birth:,
              employed: true,
            },
            additional_properties: [
              {
                value: 1_000,
                outstanding_mortgage: 0,
                percentage_owned: 99,
                shared_with_housing_assoc: false,
                subject_matter_of_dispute: false,
              },
            ],
          }
        end

        it "returns a success status flag" do
          expect(creator.success?).to be true
        end
      end
    end
  end
end
