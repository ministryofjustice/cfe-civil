require "rails_helper"

RSpec.describe CullStaleAssessmentsService do
  describe ".call" do
    subject(:cull_stale_assessment) { described_class.call }

    let!(:assessment) do
      travel_to creation_date
      assessment = create_assessment_and_associated_records
      travel_back
      assessment
    end

    context "when assessments created more than two weeks ago" do
      let(:creation_date) { (CFEConstants::STALE_ASSESSMENT_THRESHOLD_DAYS + 1).days.ago }

      it "deletes the assessment and all associated records" do
        expect(associated_model_counts_all_present?).to be true

        cull_stale_assessment

        expect(Assessment.exists?(assessment.id)).to be false
        expect(associated_model_counts_all_zero?).to be true
      end
    end

    context "when assessments created less than two weeks ago" do
      let(:creation_date) { (CFEConstants::STALE_ASSESSMENT_THRESHOLD_DAYS - 1).days.ago }

      it "does not delete any records" do
        original_record_counts = associated_model_counts

        cull_stale_assessment

        expect(Assessment.exists?(assessment.id)).to be true
        expect(associated_model_counts).to eq original_record_counts
      end
    end
  end

  def create_assessment_and_associated_records
    create(:assessment).tap do |ass|
      create :capital_summary, assessment: ass
      create :partner_capital_summary, assessment: ass
      create :partner_capital_summary, assessment: ass
      create :gross_income_summary,
             :with_all_records,
             assessment: ass
      create :partner_gross_income_summary, assessment: ass
      create :partner_gross_income_summary, assessment: ass
      create :disposable_income_summary, assessment: ass
      create :partner_disposable_income_summary, assessment: ass
      create :partner_disposable_income_summary, assessment: ass
      create :explicit_remark, assessment: ass
    end
  end

  def associated_models
    [
      CapitalSummary,
      CashTransactionCategory,
      CashTransaction,
      DisposableIncomeSummary,
      ExplicitRemark,
      GrossIncomeSummary,
      IrregularIncomePayment,
      ProceedingType,
    ]
  end

  def associated_model_counts_all_zero?
    associated_model_counts.uniq == [0]
  end

  def associated_model_counts_all_present?
    associated_model_counts.min > 0
  end

  def associated_model_counts
    associated_models.map(&:count)
  end
end
