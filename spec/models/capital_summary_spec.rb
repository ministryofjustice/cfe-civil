require "rails_helper"

RSpec.describe CapitalSummary do
  it { is_expected.to have_many(:eligibilities) }
end
