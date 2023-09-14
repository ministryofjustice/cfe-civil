require "rails_helper"

module Calculators
  RSpec.describe StatePensionDateCalculator do
    context "Increase in State Pension age from 65 to 66, men and women" do
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1954-10-06")).to_s).to eq "2020-10-06" }
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1959-10-06")).to_s).to eq "2025-10-06" }
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1960-04-05")).to_s).to eq "2026-04-05" }
    end

    context "Increase in State Pension age from 66 to 67, men and women" do
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1960-04-06")).to_s).to eq "2026-05-06" }
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1960-07-31")).to_s).to eq "2026-11-30" }
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1960-12-06")).to_s).to eq "2027-09-06" }
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1960-12-31")).to_s).to eq "2027-09-30" }
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1961-01-31")).to_s).to eq "2027-11-30" }
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1961-02-05")).to_s).to eq "2027-12-05" }
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1977-04-05")).to_s).to eq "2044-04-05" }
    end

    context "Increase in State Pension age from 67 to 68 under the Pensions Act 2007" do
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1977-04-06")).to_s).to eq "2044-05-06" }
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1977-12-06")).to_s).to eq "2045-09-06" }
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1978-04-05")).to_s).to eq "2046-03-06" }
    end

    context "when date_of_birth >= 1978-04-06 (pension_age = date_of_birth + 68)" do
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1978-04-06")).to_s).to eq "2046-04-06" }
      it { expect(described_class.state_pension_date(date_of_birth: Date.parse("1980-04-06")).to_s).to eq "2048-04-06" }
    end
  end
end
