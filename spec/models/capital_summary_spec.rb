require "rails_helper"

RSpec.describe CapitalSummary do
  it { is_expected.to belong_to(:assessment) }
end
