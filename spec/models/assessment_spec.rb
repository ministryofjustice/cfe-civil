require "rails_helper"
require Rails.root.join("spec/fixtures/assessment_request_fixture.rb")

RSpec.describe Assessment, type: :model do
  let(:payload) { AssessmentRequestFixture.json }

  it { is_expected.to have_many(:explicit_remarks) }

  context "version 6" do
    let(:param_hash) do
      {
        client_reference_id: "client-ref-1",
        submission_date: Date.current,
        remote_ip: "127.0.0.1",
      }
    end

    it "writes current date into the date column" do
      assessment = described_class.create! param_hash
      expect(assessment.created_at).to eq(Date.current)
      expect(assessment.updated_at).to eq(Date.current)
    end
  end

  context "missing ip address" do
    let(:param_hash) do
      {
        client_reference_id: "client-ref-1",
        submission_date: Date.current,
      }
    end

    it "errors" do
      assessment = described_class.create param_hash
      expect(assessment.persisted?).to be false
      expect(assessment.valid?).to be false
      expect(assessment.errors.full_messages).to include("Remote ip can't be blank")
    end
  end

  describe "#transform_remarks" do
    let(:remarks) do
      [
        Data.define(:type, :issue, :ids).new(:other_income_payment, :unknown_frequency, %w[abc def]),
        Data.define(:type, :issue, :ids).new(:other_income_payment, :amount_variation, %w[ghu jkl]),
        Data.define(:type, :issue, :ids).new(:state_benefit_payment, :residual_balance, %w[cde sss]),
      ]
    end

    let(:assessment) { create :assessment }

    subject(:transformed_remarks) { assessment.transform_remarks(remarks) }

    context "without explicit remarks" do
      it "reconstitutes into a remarks hash" do
        expect(transformed_remarks).to eq({ other_income_payment: { unknown_frequency: %w[abc def], amount_variation: %w[ghu jkl] }, state_benefit_payment: { residual_balance: %w[cde sss] } })
      end
    end

    context "with explicit remarks" do
      before { create :explicit_remark, remark: "test remark", assessment: }

      it "reconstitutes into a remarks hash with explicit remarks" do
        expect(transformed_remarks).to eq({ other_income_payment: { unknown_frequency: %w[abc def], amount_variation: %w[ghu jkl] }, state_benefit_payment: { residual_balance: %w[cde sss] }, policy_disregards: ["test remark"] })
      end
    end
  end

  describe "#proceeding_type_codes" do
    it "returns the codes from the associated proceeding type records" do
      assessment = create :assessment, proceedings: [%w[DA005 A], %w[SE014 Z]]

      expect(assessment.reload.proceeding_type_codes).to eq %w[DA005 SE014]
    end
  end
end
