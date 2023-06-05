class Assessment < ApplicationRecord
  serialize :remarks

  validates :remote_ip,
            :submission_date,
            presence: true
  validates :version, inclusion: { in: CFEConstants::VALID_ASSESSMENT_VERSIONS, message: "not valid in Accept header" }

  # Just in case we get multiple POSTs to partner endpoint
  has_many :capital_summaries, dependent: :destroy
  has_many :gross_income_summaries, dependent: :destroy
  has_many :disposable_income_summaries, dependent: :destroy

  has_one :applicant_capital_summary
  has_one :applicant_gross_income_summary
  has_one :applicant_disposable_income_summary

  has_one :partner_capital_summary
  has_one :partner_gross_income_summary
  has_one :partner_disposable_income_summary

  has_many :explicit_remarks, dependent: :destroy
  has_many :employments, dependent: :destroy, class_name: "ApplicantEmployment"
  has_many :partner_employments, dependent: :destroy
  has_many :eligibilities,
           class_name: "Eligibility::Assessment",
           foreign_key: :parent_id,
           inverse_of: :assessment,
           dependent: :destroy
  has_many :proceeding_types,
           dependent: :destroy

  enum :level_of_help, { certificated: 0, controlled: 1 }

  # Always instantiate a new Remarks object from a nil value
  def remarks
    attributes["remarks"] || Remarks.new(id)
  rescue StandardError
    Remarks.new(id)
  end

  def proceeding_type_codes
    proceeding_types.order(:ccms_code).map(&:ccms_code)
  end
end
