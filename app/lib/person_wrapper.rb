# used to convert DB layer into domain layer for rules
class PersonWrapper
  attr_reader :dependants

  def initialize(is_single:, gross_income_summary:, submission_date:, person_data:, employments:)
    @is_single = is_single
    @dependants = person_data.dependants
    @gross_income_summary = gross_income_summary
    @submission_date = submission_date
    @in_work = calculate_in_work(person_data, employments)
  end

  def in_work?
    @in_work
  end

  def is_student?
    @gross_income_summary.student_loan_payments.any?
  end

  def single?
    @is_single
  end

  def calculate_in_work(person_data, employments)
    return true if person_data.self_employments.any?
    return true if person_data.employment_details.any? { !_1.income.receiving_only_statutory_sick_or_maternity_pay }

    employments.any? { !_1.receiving_only_statutory_sick_or_maternity_pay }
  end
end
