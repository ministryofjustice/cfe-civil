module Collators
  class ChildcareCollator
    include Transactions

    class << self
      def call(submission_date:, disposable_income_summary:, dependants:, gross_income_summary:, person:)
        new(submission_date:, disposable_income_summary:, dependants:, gross_income_summary:, person:).call
      end
    end

    def initialize(submission_date:, disposable_income_summary:, dependants:, gross_income_summary:, person:)
      @submission_date = submission_date
      @disposable_income_summary = disposable_income_summary
      @dependants = dependants
      @gross_income_summary = gross_income_summary
      @person = person
    end

    def call
      @disposable_income_summary.calculate_monthly_childcare_amount!(eligible_for_childcare_costs?, monthly_child_care_cash)
    end

  private

    def eligible_for_childcare_costs?
      applicant_has_dependant_child? && (applicant_is_employed? || applicant_has_student_loan?)
    end

    def monthly_child_care_cash
      monthly_cash_transaction_amount_by(gross_income_summary: @gross_income_summary, operation: :debit, category: :child_care)
    end

    def applicant_has_dependant_child?
      @dependants.any? do |dependant|
        @submission_date.before?(dependant.becomes_adult_on)
      end
    end

    def applicant_is_employed?
      !!@person&.employed?
    end

    def applicant_has_student_loan?
      @gross_income_summary.student_loan_payments.any?
    end
  end
end
