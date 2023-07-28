class Remarks
  attr_reader :remarks_hash

  VALID_REMARK_TYPES = %i[
    other_income_payment
    state_benefit_payment
    outgoings_child_care
    outgoings_childcare
    outgoings_legal_aid
    outgoings_maintenance
    outgoings_maintenance_out
    outgoings_housing_cost
    outgoings_rent_or_mortgage
    current_account_balance
    employment_gross_income
    employment_payment
    employment_tax
    employment_nic
    employment
  ].freeze
  VALID_REMARK_ISSUES = %i[
    unknown_frequency
    amount_variation
    residual_balance
    multi_benefit
    multiple_employments
    refunds
  ].freeze

  def initialize(assessment_id)
    @assessment_id = assessment_id
    @remarks_hash = {}
  end

  def add(new_type, new_issue, new_ids)
    validate_type_and_issue(new_type, new_issue)
    @remarks_hash[new_type] = {} unless @remarks_hash.key?(new_type)
    @remarks_hash[new_type][new_issue] = [] unless @remarks_hash[new_type].key?(new_issue)
    @remarks_hash[new_type][new_issue] += new_ids
  end

  def as_json
    @remarks_hash.merge! ExplicitRemark.remarks_by_category(@assessment_id)
  end

private

  def validate_type_and_issue(type, issue)
    raise ArgumentError, "Invalid type: #{type}" unless VALID_REMARK_TYPES.include?(type)
    raise ArgumentError, "Invalid issue: #{issue}" unless VALID_REMARK_ISSUES.include?(issue)
  end
end
