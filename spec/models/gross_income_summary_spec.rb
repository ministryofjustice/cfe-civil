require "rails_helper"

RSpec.describe GrossIncomeSummary do
  let(:assessment) { create :assessment }
  let(:gross_income_summary) do
    create :gross_income_summary, assessment:
  end

  it { is_expected.to have_many(:regular_transactions).dependent(:destroy) }
end
