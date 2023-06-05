require "rails_helper"

RSpec.describe Applicant, type: :model do
  describe "#validate" do
    let(:applicant) { build(:applicant) }

    context "when date_of_birth is in the future" do
      let(:applicant) { build(:applicant, date_of_birth: Date.tomorrow) }

      before { freeze_time }

      it "is invalid" do
        expect(applicant).to be_invalid
        expect(applicant.errors.full_messages).to eq(["Date of birth cannot be in the future"])
      end
    end

    context "when all attributes are valid" do
      it "is valid" do
        expect(applicant).to be_valid
      end
    end
  end
end
