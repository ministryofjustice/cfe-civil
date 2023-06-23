require "rails_helper"

RSpec.describe Dependant, type: :model do
  let(:dependant) { build_stubbed(:dependant) }

  describe "#validate" do
    context "when date_of_birth is in the future" do
      let(:dependant) { build(:dependant, date_of_birth: Date.tomorrow) }

      before { freeze_time }

      it "is invalid" do
        expect(dependant).to be_invalid
        expect(dependant.errors.full_messages).to eq(["Date of birth cannot be in the future"])
      end
    end

    context "when all attributes are valid" do
      it "is valid" do
        dependant = build(:dependant)

        expect(dependant).to be_valid
      end
    end
  end

  describe "#becomes_16_on" do
    let(:dependant) { build(:dependant, date_of_birth: Date.new(2000, 1, 1)) }

    it "returns the dependant's 16th birthday" do
      expect(dependant.becomes_16_on).to eq Date.new(2016, 1, 1)
    end
  end
end
