class PersonGrossIncomeSubtotals
  class << self
    def blank
      new gross_income_summary: GrossIncomeSummary.new,
          regular_income_categories: [],
          employment_income_subtotals: EmploymentIncomeSubtotals.blank
    end
  end

  StateBenefitData = Data.define(:state_benefit_name, :monthly_value, :exclude_from_gross_income?)

  attr_reader :employment_income_subtotals

  def initialize(
    gross_income_summary:,
    regular_income_categories:,
    employment_income_subtotals:
  )
    @gross_income_summary = gross_income_summary
    @regular_income_categories = regular_income_categories
    @employment_income_subtotals = employment_income_subtotals
  end

  def state_benefits
    @gross_income_summary.state_benefits.map do |sb|
      StateBenefitData.new state_benefit_name: sb.state_benefit_name,
                           monthly_value: Calculators::MonthlyEquivalentCalculator.call(collection: sb.state_benefit_payments),
                           exclude_from_gross_income?: sb.exclude_from_gross_income?
    end
  end

  def total_gross_income
    employment_income_subtotals.gross_employment_income + employment_income_subtotals.benefits_in_kind +
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
    @gross_income_summary.student_loan_payments.sum { monthly_equivalent_amount(_1) }
  end

  def monthly_unspecified_source
    @gross_income_summary.unspecified_source_payments.sum { monthly_equivalent_amount(_1) }
  end

  def is_student?
    @gross_income_summary.student_loan_payments.any?
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
