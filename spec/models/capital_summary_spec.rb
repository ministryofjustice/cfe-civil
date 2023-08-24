require "rails_helper"

RSpec.describe CapitalSummary do
  let(:assessment) { create :assessment }
  let(:capital_summary) do
    create :capital_summary, assessment:
  end
end
