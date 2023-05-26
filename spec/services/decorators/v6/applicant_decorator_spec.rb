require "rails_helper"

module Decorators
  module V6
    RSpec.describe ApplicantDecorator do
      describe "#as_json" do
        subject(:decorator) { described_class.new(applicant).as_json }

        context "applicant is nil" do
          let(:applicant) { nil }

          it "returns nil" do
            expect(decorator).to be_nil
          end
        end

        context "applicant exists" do
          let(:applicant) { create :applicant }

          it "has all expected keys present in the returned hash" do
            expected_keys = %i[
              date_of_birth
              involvement_type
              employed
              has_partner_opponent
              receives_qualifying_benefit
            ]
            expect(decorator.keys).to eq expected_keys
          end
        end
      end
    end
  end
end
