require "rails_helper"

RSpec.describe BankHoliday do
  describe ".dates" do
    before do
      allow(GovukBankHolidayRetriever).to receive(:dates).and_return(expected_dates)
    end

    context "data returned from API" do
      it "returns an array of dates for England and Wales" do
        expect(GovukBankHolidayRetriever).to receive(:dates)
        expect(described_class.dates).to eq expected_dates
      end
    end

    context "data returned from cache" do
      it "returns an array of dates for England and Wales" do
        expect(GovukBankHolidayRetriever).to receive(:dates).once
        expect(described_class.dates).to eq expected_dates
        expect(described_class.dates).to eq expected_dates
      end
    end

    context "third call (after 10 days) - data returned from API" do
      it "returns an array of dates for England and Wales" do
        expect(GovukBankHolidayRetriever).to receive(:dates).twice
        expect(described_class.dates).to eq expected_dates
        expect(described_class.dates).to eq expected_dates
        travel 11.days do
          expect(described_class.dates).to eq expected_dates
        end
      end
    end

    context "fourth call - data returned from cache (3rd call version)" do
      it "returns an array of dates for England and Wales" do
        expect(GovukBankHolidayRetriever).to receive(:dates).twice
        expect(described_class.dates).to eq expected_dates
        expect(described_class.dates).to eq expected_dates
        travel 11.days do
          expect(described_class.dates).to eq expected_dates
          expect(described_class.dates).to eq expected_dates
        end
      end
    end
  end

  def expected_dates
    %w[2015-01-01 2015-04-03 2015-04-06]
  end
end
