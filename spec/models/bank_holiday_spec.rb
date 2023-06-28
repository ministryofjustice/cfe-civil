require "rails_helper"

RSpec.describe BankHoliday do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cache) { Rails.cache }

  describe ".dates" do
    # before do
    #   allow(GovukBankHolidayRetriever).to receive(:dates).and_return(expected_dates)
    # end

    before do
      stub_request(:get, "https://www.gov.uk/bank-holidays.json").to_return(body: json_response.to_json, status: 200)
      allow(Rails).to receive(:cache).and_return(memory_store)
      Rails.cache.clear
    end

    context "data returned from API" do
      it "calls the API once" do
        # expect(GovukBankHolidayRetriever).to receive(:dates).once
        expect(described_class.dates).to eq expected_dates
        expect(a_request(:get, "https://www.gov.uk/bank-holidays.json")).to have_been_made.at_most_times(1)
      end
    end

    context "data returned from cache" do
      it "calls the API once" do
        # expect(GovukBankHolidayRetriever).to receive(:dates).once
        expect(described_class.dates).to eq expected_dates
        expect(described_class.dates).to eq expected_dates
        expect(a_request(:get, "https://www.gov.uk/bank-holidays.json")).to have_been_made.at_most_times(1)
      end
    end

    context "data returned from API after 10 days" do
      it "calls the API once" do
        # expect(GovukBankHolidayRetriever).to receive(:dates).twice
        expect(described_class.dates).to eq expected_dates
        expect(described_class.dates).to eq expected_dates
        travel 11.days do
          expect(described_class.dates).to eq expected_dates
        end
        expect(a_request(:get, "https://www.gov.uk/bank-holidays.json")).to have_been_made.at_most_times(2)
      end
    end

    context "data returned from cache after 10 days" do
      it "calls the API twice" do
        # expect(GovukBankHolidayRetriever).to receive(:dates).twice
        expect(described_class.dates).to eq expected_dates
        expect(described_class.dates).to eq expected_dates
        travel 11.days do
          expect(described_class.dates).to eq expected_dates
          expect(described_class.dates).to eq expected_dates
        end
        expect(a_request(:get, "https://www.gov.uk/bank-holidays.json")).to have_been_made.at_most_times(2)
      end
    end
  end

  def expected_dates
    %w[2015-01-01 2015-04-03 2015-04-06]
  end

  def json_response
    {
      "england-and-wales" => {
        "division" => "england-and-wales",
        "events" => [
          {
            "title" => "New Year’s Day",
            "date" => "2015-01-01",
            "notes" => "",
            "bunting" => true,
          },
          {
            "title" => "Good Friday",
            "date" => "2015-04-03",
            "notes" => "",
            "bunting" => false,
          },
          {
            "title" => "Easter Monday",
            "date" => "2015-04-06",
            "notes" => "",
            "bunting" => true,
          },
        ],
      },
      "scotland" => {
        "division" => "scotland",
        "events" => [
          {
            "title" => "New Year’s Day",
            "date" => "2015-01-01",
            "notes" => "",
            "bunting" => true,
          },
          {
            "title" => "2nd January",
            "date" => "2015-01-02",
            "notes" => "",
            "bunting" => true,
          },
          {
            "title" => "Good Friday",
            "date" => "2015-04-03",
            "notes" => "",
            "bunting" => false,
          },
        ],
      },
    }
  end
end
