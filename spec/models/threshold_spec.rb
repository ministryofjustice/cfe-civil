require "rails_helper"

RSpec.describe Threshold do
  context "using test data files" do
    let(:threshold_test_data_folder) { "spec/data/thresholds" }
    let(:thresholds) { described_class.new(threshold_test_data_folder) }

    describe ".value_for" do
      let(:time) { Time.zone.parse("9-June-2019 12:35") }
      let(:test_data_file) { "#{threshold_test_data_folder}/2019-04-08.yml" }
      let(:data) { YAML.load_file(test_data_file).deep_symbolize_keys }

      it "returns the expected value" do
        expect(thresholds.value_for(:capital_lower_certificated, at: time)).to eq(data[:capital_lower_certificated])
      end

      context "for dates before oldest" do
        let(:time) { Time.zone.parse("9-June-2001 12:35") }
        let(:path) { data_file_path("thresholds/8-Apr-2018.yml") }
        let(:data) { YAML.load_file("#{threshold_test_data_folder}/2018-04-08.yml").deep_symbolize_keys }

        it "returns the value from oldest file" do
          expect(thresholds.value_for(:capital_lower_certificated, at: time)).to eq(data[:capital_lower_certificated])
        end
      end
    end
  end

  context "using live files" do
    context "before 2020-04-06" do
      let(:time) { Time.zone.parse("01-Apr-2020") }
      let(:expected_dependant_allowances) do
        {
          child_under_15: 291.49,
          child_aged_15: 291.49,
          child_16_and_over: 291.49,
          adult: 291.49,
          adult_capital_threshold: 8_000,
        }
      end

      it "retrieves values from the 2019-04-08 file" do
        expect(described_class.value_for(:dependant_allowances, at: time)).to eq expected_dependant_allowances
      end
    end

    context "on 2020-04-06" do
      let(:time) { Time.zone.parse("06-Apr-2020") }
      let(:expected_dependant_allowances) do
        {
          child_under_15: 296.65,
          child_aged_15: 296.65,
          child_16_and_over: 296.65,
          adult: 296.65,
          adult_capital_threshold: 8_000,
        }
      end

      it "picks up the values from the 2020-04-06 file" do
        expect(described_class.value_for(:dependant_allowances, at: time)).to eq expected_dependant_allowances
      end
    end

    context "8th April 2024" do
      let(:time) { Time.zone.parse("08-Apr-2024") }
      let(:expected_dependant_allowances) do
        {
          child_under_15: 361.70,
          child_aged_15: 361.70,
          child_16_and_over: 361.70,
          adult: 361.70,
          adult_capital_threshold: 8_000,
        }
      end

      it "picks up the values from the 2024-04-08 file" do
        expect(described_class.value_for(:dependant_allowances, at: time)).to eq expected_dependant_allowances
      end

      it "has a new partner allowance" do
        expect(described_class.value_for(:partner_allowance, at: time)).to eq(224.87)
      end
    end
  end

  context "7th April 2025" do
    let(:time) { Time.zone.parse("07-Apr-2025") }
    let(:expected_dependant_allowances) do
      {
        child_under_15: 367.87,
        child_aged_15: 367.87,
        child_16_and_over: 367.87,
        adult: 367.87,
        adult_capital_threshold: 8_000,
      }
    end

    it "picks up the values from the 2025-04-07 file" do
      expect(described_class.value_for(:dependant_allowances, at: time)).to eq expected_dependant_allowances
    end

    it "has a new partner allowance" do
      expect(described_class.value_for(:partner_allowance, at: time)).to eq(228.56)
    end
  end

  context "MTR" do
    context "when setting future test file" do
      before { allow(Rails.configuration.x).to receive(:future_test_data_file).and_return(override_filename) }

      let(:submission_date) { Time.zone.today }

      # This test will fail if it is ran on the same date as the effective date of another threshold file in config/thresholds/values.yml.
      # This is because the test assigns both files the same effective date and the values in whichever file is listed first are applied.
      # To (temporarily) skip this test on that date change context below to xcontext.
      context "when future test file active" do
        let(:override_filename) { "mtr-2026.yml" }

        it "invokes the MTR config early regardless of submission date" do
          expect(described_class.new.value_for(:fixed_employment_allowance, at: submission_date)).to eq 66.0
        end
      end

      context "when future test file inactive" do
        let(:override_filename) { "" }

        it "doesnt invoke MTR threshold" do
          expect(described_class.new.value_for(:fixed_employment_allowance, at: submission_date)).to eq 45.0
        end
      end
    end

    context "with MTR" do
      let(:submission_date) { Date.new(2525, 4, 20) }

      it "retrieves values from the mtr-2026 file" do
        expect(described_class.value_for(:fixed_employment_allowance, at: submission_date)).to eq 66.0
        expect(described_class.value_for(:property_disregard, at: submission_date)[:main_home]).to eq 185_000.0
        expect(described_class.value_for(:subject_matter_of_dispute_disregard, at: submission_date)).to eq 999_999_999_999
        expect(described_class.value_for(:disposable_income_lower_controlled, at: submission_date)).to eq 946
        expect(described_class.value_for(:disposable_income_upper, at: submission_date)).to eq 946
      end
    end

    context "without MTR" do
      let(:submission_date) { Date.new(2022, 4, 20) }

      it "retrieves values from the mtr-2026 file" do
        expect(described_class.value_for(:fixed_employment_allowance, at: submission_date)).to eq 45.0
        expect(described_class.value_for(:property_disregard, at: submission_date)[:main_home]).to eq 100_000.0
        expect(described_class.value_for(:subject_matter_of_dispute_disregard, at: submission_date)).to eq 100_000.0
        expect(described_class.value_for(:disposable_income_lower_controlled, at: submission_date)).to eq 733
        expect(described_class.value_for(:disposable_income_upper, at: submission_date)).to eq 733
      end
    end
  end
end
