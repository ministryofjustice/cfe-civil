module Exemptable
  def exempt_from_checking
    childcare_payment? && childcare_disallowed?
  end

  def childcare_payment?
    record_type == :outgoings_childcare
  end

  def childcare_disallowed?
    @disposable_income_summary.child_care_bank.zero?
  end
end
