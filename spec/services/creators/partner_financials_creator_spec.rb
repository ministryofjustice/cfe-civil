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
