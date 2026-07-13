require "pact"
require "pact/rspec"

UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i

RSpec.shared_context "with legal framework api consumer pact" do
  has_http_pact_between "cfe-civil", "legal-framework-api", opts: { pact_dir: "spec/pacts" }
end
