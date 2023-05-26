module RemarkGenerators
  class Orchestrator
    attr_reader :assessment

    delegate :state_benefit_payments, to: :state_benefits

    def self.call(assessment, assessed_capital)
      new(assessment, assessed_capital).call
    end

    def initialize(assessment, assessed_capital)
      @assessment = assessment
      @assessed_capital = assessed_capital
    end

    def call
      check_amount_variations
      check_frequencies
      check_residual_balances
      check_flags
    end

  private

    def check_amount_variations
      check_state_benefit_variations
      check_other_income_variaions
      check_outgoings_variation
    end

    def check_state_benefit_variations
      state_benefits.each { |sb| AmountVariationChecker.call(@assessment, sb.state_benefit_payments) }
    end

    def check_other_income_variaions
      other_income_sources.each { |oi| AmountVariationChecker.call(@assessment, oi.other_income_payments) }
    end

    def check_outgoings_variation
      assessment.applicant_disposable_income_summary.outgoings.group_by(&:type).each do |_type, collection|
        AmountVariationChecker.call(@assessment, collection)
      end
    end

    def check_frequencies
      state_benefits.each { |sb| FrequencyChecker.call(@assessment, sb.state_benefit_payments) }
      other_income_sources.each { |oi| FrequencyChecker.call(@assessment, oi.other_income_payments) }
      outgoings.group_by(&:type).each do |_type, collection|
        FrequencyChecker.call(@assessment, collection)
      end
      assessment.employments.each do |job|
        FrequencyChecker.call(@assessment, job.employment_payments, :date)
      end
    end

    def check_residual_balances
      ResidualBalanceChecker.call(@assessment, @assessed_capital)
    end

    def check_flags
      state_benefits.each { |sb| MultiBenefitChecker.call(@assessment, sb.state_benefit_payments) }
    end

    # These 3 methods are both possible sources of (minor) defects
    # because we're not passing gross_income_summary or disposable_income_summary
    def state_benefits
      assessment.applicant_gross_income_summary.state_benefits
    end

    def other_income_sources
      assessment.applicant_gross_income_summary.other_income_sources
    end

    def outgoings
      assessment.applicant_disposable_income_summary.outgoings
    end
  end
end
