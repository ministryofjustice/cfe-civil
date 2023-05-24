module Calculators
  class TaxNiRefundCalculator
    KEY_MAPPING = {
      tax: :employment_tax,
      national_insurance: :employment_nic,
    }.freeze

    class << self
      def call(employment_payments:)
        employment_payments.flat_map do |payment|
          attrs = {}
          attrs[:tax] = 0 if payment.tax >= 0
          attrs[:national_insurance] = 0 if payment.national_insurance >= 0

          if attrs.empty?
            []
          else
            payment.update!(attrs)
            attrs.keys.map do |key|
              RemarksData.new(type: KEY_MAPPING.fetch(key), issue: :refunds, ids: [payment.client_id])
            end
          end
        end
      end
    end
  end
end
