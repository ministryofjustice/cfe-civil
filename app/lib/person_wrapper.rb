# used to convert DB layer into domain layer for rules
class PersonWrapper
  attr_reader :dependants

  def initialize(employed:, is_single:, dependants:, gross_income_summary:, submission_date:)
    @employed = employed
    @is_single = is_single
    @dependants = dependants
    @gross_income_summary = gross_income_summary
    @submission_date = submission_date
  end

  def employed?
    @employed
  end

  def is_student?
    @gross_income_summary.student_loan_payments.any?
  end

  def single?
    @is_single
  end
end
