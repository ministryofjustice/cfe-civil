require "rails_helper"

RSpec.describe SwaggerLoader do
  let(:schema) { described_class.load_response_schema version }

  context "with version 6" do
    let(:version) { 6 }

    it "has a full schema" do
      expect(allowed_additional_properties("response", schema)).to eq([])
    end
  end

  context "with version 7" do
    let(:version) { 7 }

    it "has a full schema" do
      expect(allowed_additional_properties("response", schema)).to eq([])
    end
  end

  def allowed_additional_properties(name, schema_hash)
    additional = []
    if schema_hash["type"] == "object"
      additional << name if schema_hash.fetch("additionalProperties", true)
      values = schema_hash.fetch("properties", []).map do |key, value|
        allowed_additional_properties(key, value)
      end
      additional + values.reduce([], &:+)
    else
      additional
    end
  end
end
