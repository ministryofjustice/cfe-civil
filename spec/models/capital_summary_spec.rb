require "rails_helper"

RSpec.describe CapitalSummary do
  it { is_expected.to belong_to(:assessment) }
  it { is_expected.to have_many(:eligibilities).class_name("Eligibility::Capital").with_foreign_key(:parent_id).inverse_of(:capital_summary).dependent(:destroy) }
end
