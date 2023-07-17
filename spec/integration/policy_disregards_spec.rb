require "rails_helper"

RSpec.describe "Eligible Full Assessment with policy disregard remarks", :calls_bank_holiday do
  let(:client_id) { "uuid or any unique string" }

  before do
    Dibber::Seeder.new(StateBenefitType,
                       "data/state_benefit_types.yml",
                       name_method: :label,
                       overwrite: true).build

    ENV["VERBOSE"] = "false"
  end

  it "returns the expected payload with no policy disregards remarks" do
    post_assessment
    expect(parsed_response[:assessment][:remarks]).not_to include(:policy_disregards)
  end

  def post_assessment
    post v6_assessments_path, params: payload.to_json, headers: headers
    output_response(:post, :assessment)
  end

  def output_response(method, object)
    puts ">>>>>>>>>>>> #{method.to_s.upcase} #{object} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n" if verbose?
    ap parsed_response if verbose?
    raise "Bad response: #{response.status}" unless response.status == 200
  end

  def verbose?
    ENV["VERBOSE"] == "true"
  end

  def headers
    { "CONTENT_TYPE" => "application/json", "Accept" => "application/json;version=6" }
  end

  def payload
    [
      *assessment_params,
      *applicant_params,
      *proceeding_types_params,
      *capitals_params,
      *dependants_params,
      *other_income_params,
      *outgoings_params,
      *state_benefit_params,
      *irregular_income_params,
      *explicit_remarks_params,
    ].to_h
  end

  def assessment_params
    {
      assessment:
        {
          client_reference_id: "L-YYV-4N6",
          submission_date: "2020-06-11",
        },
    }
  end

  def applicant_params
    {
      applicant:
          {
            date_of_birth: "1981-04-11",
            has_partner_opponent: false,
            receives_qualifying_benefit: false,
          },
    }
  end

  def proceeding_types_params
    {
      proceeding_types: [
        { ccms_code: "DA004", client_involvement_type: "A" },
        { ccms_code: "DA020", client_involvement_type: "A" },
        { ccms_code: "SE004", client_involvement_type: "A" },
        { ccms_code: "SE013", client_involvement_type: "A" },
      ],
    }
  end

  def capitals_params
    {
      capitals: {
        bank_accounts:
          [{ description: "Money not in a bank account", value: 50.0 }],
        non_liquid_capital:
            [{ description: "Any valuable items worth more than £500", value: 700.0 }],
      },
    }
  end

  def dependants_params
    {
      dependants: [{
        date_of_birth: "2010-03-05",
        relationship: "child_relative",
        monthly_income: 0.0,
        in_full_time_education: false,
        assets_value: 0.0,
      }],
    }
  end

  def other_income_params
    {
      other_incomes:
          [
            { source: "Friends or family",
              payments:
                 [
                   { date: "2020-04-11",
                     amount: 22.42,
                     client_id: "TX-other-income-friends-family-1" },
                   { date: "2020-05-11",
                     amount: 50.0,
                     client_id: "TX-other-income-friends-family-2" },
                   { date: "2020-06-09",
                     amount: 70.0,
                     client_id: "TX-other-income-friends-family-3" },
                 ] },
            { source: "Maintenance in",
              payments:
                  [
                    { date: "2020-04-04",
                      amount: 25.0,
                      client_id: "TX-other-income-maintenance-in-1" },
                    { date: "2020-05-14",
                      amount: 43.5,
                      client_id: "TX-other-income-maintenance-in-2" },
                    { date: "2020-06-10",
                      amount: 50.36,
                      client_id: "TX-other-income-maintenance-in-3" },
                  ] },
            { source: "Pension",
              payments:
                  [
                    { date: "2020-04-10",
                      amount: 40.0,
                      client_id: "TX-other-income-pension-1" },
                    { date: "2020-05-06",
                      amount: 137.6,
                      client_id: "TX-other-income-pension-2" },
                    { date: "2020-06-09",
                      amount: 70.0,
                      client_id: "TX-other-income-pension-3" },
                  ] },
            { source: "Property or lodger",
              payments:
                  [
                    { date: "2020-04-06",
                      amount: 137.6,
                      client_id: "TX-other-income-property-1" },
                    { date: "2020-05-03",
                      amount: 35.49,
                      client_id: "TX-other-income-property-2" },
                    { date: "2020-06-11",
                      amount: 50.0,
                      client_id: "TX-other-income-property-3" },
                  ] },
          ],
    }
  end

  def outgoings_params
    {
      outgoings:
          [
            { name: "maintenance_out",
              payments:
                 [
                   { payment_date: "2020-04-22",
                     amount: 0.01,
                     client_id: "TX-outgoing-maintenance-1" },
                   { payment_date: "2020-05-19",
                     amount: 7.99,
                     client_id: "TX-outgoing-maintenance-2" },
                   { payment_date: "2020-06-10",
                     amount: 5.0,
                     client_id: "TX-outgoing-maintenance-3" },
                 ]  },
            { name: "rent_or_mortgage",
              payments:
                  [
                    { payment_date: "2020-04-22",
                      amount: 36.59,
                      housing_cost_type: "rent",
                      client_id: "TX-outgoing-rent-mortgage-1" },
                    { payment_date: "2020-05-23",
                      amount: 100.0,
                      housing_cost_type: "rent",
                      client_id: "TX-outgoing-rent-mortgage-2" },
                    { payment_date: "2020-06-01",
                      amount: 46.82,
                      housing_cost_type: "rent",
                      client_id: "TX-outgoing-rent-mortgage-3" },
                  ] },
            { name: "child_care",
              payments:
                  [
                    { payment_date: "2020-04-23",
                      amount: 20.0,
                      client_id: "TX-outgoing-rent-child_care-1" },
                    { payment_date: "2020-05-25",
                      amount: 10.5,
                      client_id: "TX-outgoing-rent-child_care-2" },
                    { payment_date: "2020-06-10",
                      amount: 40.0,
                      client_id: "TX-outgoing-rent-child_care-3" },
                  ] },
            { name: "legal_aid",
              payments:
                  [
                    { payment_date: "2020-04-25",
                      amount: 24.5,
                      client_id: "TX-outgoing-rent-legal-aid-1" },
                    { payment_date: "2020-05-22",
                      amount: 36.59,
                      client_id: "TX-outgoing-rent-legal-aid-2" },
                    { payment_date: "2020-06-09",
                      amount: 20.56,
                      client_id: "TX-outgoing-rent-legal-aid-3" },
                  ] },
          ],
    }
  end

  def state_benefit_params
    {
      state_benefits:
          [
            { name: "Manually chosen",
              payments:
                 [
                   { date: "2020-04-10",
                     amount: 50.36,
                     client_id: "TX-state-benefits-1" },
                   { date: "2020-05-28",
                     amount: 40.0,
                     client_id: "TX-state-benefits-2" },
                   { date: "2020-06-06",
                     amount: 22.42,
                     client_id: "TX-state-benefits-3" },
                 ] },
          ],
    }
  end

  def irregular_income_params
    { irregular_incomes:
    {
      payments: [
        { income_type: "student_loan",
          frequency: "annual",
          amount: 100.0 },
        { income_type: "unspecified_source",
          frequency: "quarterly",
          amount: 303.0 },
      ],
    } }
  end

  def explicit_remarks_params
    {
      explicit_remarks: [
        {
          category: "policy_disregards",
          details: [
            "Grenfell tower fund",
            "Some other fund",
          ],
        },
      ],
    }
  end
end
