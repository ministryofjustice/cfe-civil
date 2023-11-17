class ProceedingType < ApplicationRecord
  belongs_to :assessment

  # client_involvement_types
  # Applicant/claimant/petitioner A
  # Defendant/respondent D
  # Subject of proceedings (child) W
  # Intervenor I
  # Joined party Z
  # Domestic abuse waivers will only be applied for client_involvement_type == 'A'
  VALID_CLIENT_INVOLVEMENT_TYPES = %w[A D W Z I].freeze

  validates :client_involvement_type, inclusion: { in: VALID_CLIENT_INVOLVEMENT_TYPES,
                                                   message: "invalid client_involvement_type: %{value}",
                                                   allow_nil: true }
  validate :proceeding_type_code_validations

  validates :ccms_code, uniqueness: { scope: :assessment_id }

private

  def proceeding_type_code_validations
    errors.add(:ccms_code, "invalid ccms_code: #{ccms_code}") unless ccms_code.to_sym.in?(CFEConstants::VALID_PROCEEDING_TYPE_CCMS_CODES)
  end
end
