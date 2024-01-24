class ProceedingType
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :client_involvement_type, :string
  attribute :ccms_code, :string
  attribute :gross_income_upper_threshold, :decimal
  attribute :disposable_income_upper_threshold, :decimal
  attribute :capital_upper_threshold, :decimal

  # client_involvement_types
  # Applicant/claimant/petitioner A
  # Defendant/respondent D
  # Subject of proceedings (child) W
  # Intervenor I
  # Joined party Z
  # Domestic abuse waivers will only be applied for client_involvement_type == 'A'
  VALID_CLIENT_INVOLVEMENT_TYPES = %w[A D W Z I].freeze

  def immigration_case?
    ccms_code.to_sym == CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE
  end

  def asylum_case?
    ccms_code.to_sym == CFEConstants::ASYLUM_PROCEEDING_TYPE_CCMS_CODE
  end
end
