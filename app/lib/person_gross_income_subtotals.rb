class PersonGrossIncomeSubtotals
  class << self
    def blank
      new student_loan_payments: [],
          unspecified_source_payments: [],
          regular_income_categories: [],
          employment_income_subtotals: EmploymentIncomeSubtotals.blank,
          state_benefits: []
    end
  end

  StateBenefitData = Data.define(:state_benefit_name, :monthly_value, :exclude_from_gross_income?)

  attr_reader :employment_income_subtotals

  def initialize(
    student_loan_payments:,
    unspecified_source_payments:,
    regular_income_categories:,
    employment_income_subtotals:,
    state_benefits:
  )
    @student_loan_payments = student_loan_payments
    @unspecified_source_payments = unspecified_source_payments
    @regular_income_categories = regular_income_categories
    @employment_income_subtotals = employment_income_subtotals
    @state_benefits = state_benefits
  end

  def state_benefits
    @state_benefits.map do |sb|
      StateBenefitData.new state_benefit_name: sb.state_benefit_name,
                           monthly_value: Calculators::MonthlyEquivalentCalculator.call(collection: sb.state_benefit_payments),
                           exclude_from_gross_income?: sb.exclude_from_gross_income?
    end
  end

  def total_gross_income
    @employment_income_subtotals.gross_employment_income + @employment_income_subtotals.benefits_in_kind +
      @regular_income_categories.sum(&:all_sources) +
      monthly_student_loan +
      monthly_unspecified_source
  end

  def monthly_regular_incomes(income_type, income_category)
    category_data = @regular_income_categories.find { _1.category == income_category }
    return 0 unless category_data

    category_data.send(income_type)
  end

  def monthly_student_loan
    @student_loan_payments.sum { monthly_equivalent_amount(_1) }
  end

  def monthly_unspecified_source
    @unspecified_source_payments.sum { monthly_equivalent_amount(_1) }
  end

  def is_student?
    # GUIDANCE quote:
    # 'Where the individual or their partner is assessed as receiving a wage or
    # salary from employment, or an income from self-employment, or studyrelated income (i.e. student loan, student grant or other income received
    # from a person who is not their partner or relative for the purpose of
    # supporting the individual’s course of study)'
    @student_loan_payments.any?
  end

private

  def monthly_equivalent_amount(payment)
    payment.amount / MONTHS_PER_PERIOD.fetch(payment.frequency)
  end

  MONTHS_PER_PERIOD = {
    CFEConstants::ANNUAL_FREQUENCY => 12,
    CFEConstants::QUARTERLY_FREQUENCY => 3,
    CFEConstants::MONTHLY_FREQUENCY => 1,
  }.freeze
end
