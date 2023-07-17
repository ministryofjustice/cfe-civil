require "rails_helper"

module RemarkGenerators
  RSpec.describe FrequencyChecker, :calls_bank_holiday do
    around do |example|
      travel_to Date.new(2021, 4, 15) # avoid problems because of 29th Feb
      example.run
      travel_back
    end

    context "when checking state benefit payments" do
      let(:amount) { 123.45 }
      let(:dates) { [Date.current, 1.month.ago, 2.months.ago] }
      let(:state_benefit) { create :state_benefit }
      let(:assessment) { state_benefit.gross_income_summary.assessment }
      let(:payment1) { create :state_benefit_payment, state_benefit:, amount:, payment_date: dates[0] }
      let(:payment2) { create :state_benefit_payment, state_benefit:, amount:, payment_date: dates[1] }
      let(:payment3) { create :state_benefit_payment, state_benefit:, amount:, payment_date: dates[2] }
      let(:collection) { [payment1, payment2, payment3] }

      context "with regular dates" do
        let(:dates) { [Date.current, 1.month.ago, 2.months.ago] }

        it "does not update the remarks class" do
          expect(described_class.call(assessment.applicant_disposable_income_summary, collection)).to be_nil
        end
      end

      context "with irregular dates" do
        let(:dates) { [2.days.ago, 10.days.ago, 55.days.ago] }

        it "adds the remark" do
          expect(described_class.call(assessment.applicant_disposable_income_summary, collection))
            .to eq(
              RemarksData.new(type: :state_benefit_payment, issue: :unknown_frequency, ids: collection.map(&:client_id)),
            )
        end
      end
    end

    context "when checking outgoings" do
      let(:disposable_income_summary) { create :disposable_income_summary }
      let(:assessment) { disposable_income_summary.assessment }
      let(:amount) { 277.67 }
      let(:collection) do
        [
          create(:legal_aid_outgoing, disposable_income_summary:, payment_date: dates[0], amount:),
          create(:legal_aid_outgoing, disposable_income_summary:, payment_date: dates[1], amount:),
          create(:legal_aid_outgoing, disposable_income_summary:, payment_date: dates[2], amount:),
        ]
      end

      context "with regular dates" do
        let(:dates) { [Date.current, 1.month.ago, 2.months.ago] }

        it "does not update the remarks class" do
          expect(described_class.call(assessment.applicant_disposable_income_summary, collection)).to be_nil
        end
      end

      context "with irregular dates" do
        let(:dates) { [Date.current, 1.week.ago, 9.weeks.ago] }

        it "adds the remark" do
          expect(described_class.call(assessment.applicant_disposable_income_summary, collection))
            .to eq(
              RemarksData.new(type: :outgoings_legal_aid, issue: :unknown_frequency, ids: collection.map(&:client_id)),
            )
        end

        context "when childcare costs with an amount variation are declared" do
          let(:collection) do
            [
              create(:childcare_outgoing, disposable_income_summary:, payment_date: dates[0], amount:),
              create(:childcare_outgoing, disposable_income_summary:, payment_date: dates[1], amount: amount + 0.01),
              create(:childcare_outgoing, disposable_income_summary:, payment_date: dates[2], amount:),
            ]
          end

          context "if the childcare costs are allowed as an outgoing" do
            before { disposable_income_summary.update!(child_care_bank: 1) }

            it "adds the remark" do
              expect(described_class.call(assessment.applicant_disposable_income_summary, collection))
                .to eq(
                  RemarksData.new(type: :outgoings_childcare, issue: :unknown_frequency, ids: collection.map(&:client_id)),
                )
            end
          end

          context "if the childcare costs are not allowed as an outgoing" do
            it "does not update the remarks class" do
              expect(described_class.call(assessment.applicant_disposable_income_summary, collection)).to be_nil
            end
          end
        end
      end
    end

    context "when checking employment_payments" do
      let(:gross_income_summary) { create :gross_income_summary, :with_everything }
      let(:assessment) { gross_income_summary.assessment }
      let(:amount) { 277.67 }

      let(:collection) { employment.employment_payments }

      context "with regular dates" do
        let(:employment) { create :employment, :with_monthly_payments, assessment: gross_income_summary.assessment }

        it "does not update the remarks class" do
          expect(described_class.call(assessment.applicant_disposable_income_summary, collection, "date")).to be_nil
        end
      end

      context "with irregular dates" do
        let(:employment) { create :employment, :with_irregular_payments, assessment: gross_income_summary.assessment }

        it "adds the remark" do
          expect(described_class.call(assessment.applicant_disposable_income_summary, collection, "date"))
            .to eq(
              RemarksData.new(type: :employment_payment, issue: :unknown_frequency, ids: collection.map(&:client_id)),
            )
        end
      end
    end
  end
end
