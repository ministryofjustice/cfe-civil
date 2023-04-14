require "rails_helper"

module Creators
  RSpec.describe VehicleCreator do
    let(:assessment) { create :assessment, :with_capital_summary }
    let(:capital_summary) { assessment.capital_summary }
    let(:vehicles) { attributes_for_list(:vehicle, 2) }
    let(:vehicles_params) { { vehicles: vehicles.map { |v| v.tap { |h| h[:date_of_purchase] = h[:date_of_purchase].to_s } } } }

    describe ".call" do
      subject(:service) do
        described_class.call(
          capital_summary: assessment.capital_summary,
          vehicles_params:,
        )
      end

      it "generates two vehicles" do
        expect { service }.to change { assessment.vehicles.count }.by(2)
      end

      it "is successful" do
        expect(service).to be_success
      end

      it "has empty errors" do
        expect(service.errors).to be_empty
      end

      context "with error" do
        let(:vehicles) { attributes_for_list(:vehicle, 2, date_of_purchase: Faker::Date.between(from: 2.months.from_now, to: 6.years.from_now)) }

        it "does not generates two vehicles" do
          expect { service }.not_to change(assessment.vehicles, :count)
        end

        it "is unsuccessful" do
          expect(service).not_to be_success
        end

        it "returns an error" do
          expect(service.errors).to eq(["Date of purchase cannot be in the future"])
        end
      end
    end
  end
end
