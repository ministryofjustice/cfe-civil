require "rails_helper"

RSpec.describe BankHoliday do
  describe ".dates" do
    let(:bank_holiday_stub) {
      stub_request(:get, "https://www.gov.uk/bank-holidays.json").to_return(body: json_response.to_json, status: 200)
    }
    let(:bank_holiday_stub_again) {
      stub_request(:get, "https://www.gov.uk/bank-holidays.json").to_return(body: json_response.to_json, status: 200)
    }
    before do
      bank_holiday_stub
    end

    context "data returned from API" do
      it "calls the API once" do
        expect(described_class.dates).to eq expected_dates
      end
    end

    context "data returned from cache" do
      it "calls the API once" do
        expect(described_class.dates).to eq expected_dates
        remove_request_stub(bank_holiday_stub)
        expect(described_class.dates).to eq expected_dates
      end
    end

    context "data returned from API after 10 days" do
      it "calls the API once" do
        expect(described_class.dates).to eq expected_dates
        remove_request_stub(bank_holiday_stub)
        expect(described_class.dates).to eq expected_dates
        bank_holiday_stub_again
        travel 11.days do
          expect(described_class.dates).to eq expected_dates
        end
      end
    end

    context "data returned from cache after 10 days" do
      it "calls the API twice" do
        # expect(GovukBankHolidayRetriever).to receive(:dates).twice
        expect(described_class.dates).to eq expected_dates
        remove_request_stub(bank_holiday_stub)
        expect(described_class.dates).to eq expected_dates
        bank_holiday_stub_again
        travel 11.days do
          expect(described_class.dates).to eq expected_dates
          remove_request_stub(bank_holiday_stub_again)
          expect(described_class.dates).to eq expected_dates
        end
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
