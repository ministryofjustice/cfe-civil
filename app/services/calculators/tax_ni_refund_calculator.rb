module Calculators
  class TaxNiRefundCalculator
    def self.call(employment)
      new(employment).call
    end

    def initialize(employment)
      @employment = employment
    end

    def call
      @employment.employment_payments.each do |payment|
        attrs = {}
        attrs[:tax] = 0 if payment.tax >= 0
        attrs[:national_insurance] = 0 if payment.national_insurance >= 0

        update_and_add_remarks(attrs, payment) unless attrs.empty?
      end
    end

  private

    def update_and_add_remarks(attrs, payment)
      payment.update!(attrs)
      my_remarks = @employment.assessment.remarks
      my_remarks.add(:employment_tax, :refunds, [payment.client_id]) if attrs.key?(:tax)
      my_remarks.add(:employment_nic, :refunds, [payment.client_id]) if attrs.key?(:national_insurance)
      @employment.assessment.update!(remarks: my_remarks)
    end
  end
end
