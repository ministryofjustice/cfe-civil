module Calculators
  class TaxNiRefundCalculator
    KEY_MAPPING = {
      tax: :employment_tax,
      national_insurance: :employment_nic,
    }.freeze

    #  return is an array of these objects
    Result = Data.define(:payment, :remarks)

    class << self
      def call(employment_payments:)
        employment_payments.map do |payment|
          attrs = {}
          attrs[:tax] = 0 if payment.tax >= 0
          attrs[:national_insurance] = 0 if payment.national_insurance >= 0

          new_payment = EmploymentPayment.new date: payment.date,
                                              gross_income: payment.gross_income,
                                              tax: payment.tax,
                                              national_insurance: payment.national_insurance,
                                              prisoner_levy: payment.prisoner_levy,
                                              client_id: payment.client_id,
                                              benefits_in_kind: payment.benefits_in_kind

          new_payment.assign_attributes(attrs)

          remarks = attrs.keys.map do |key|
            RemarksData.new(type: KEY_MAPPING.fetch(key), issue: :refunds, ids: [payment.client_id])
          end

          Result.new(payment: new_payment, remarks:)
        end
      end
    end
  end
end
