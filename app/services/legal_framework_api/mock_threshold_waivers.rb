module LegalFrameworkAPI
  class MockThresholdWaivers
    class << self
      def call(proceeding_type_details)
        {
          request_id: SecureRandom.uuid,
          success: true,
          proceedings: proceeding_type_details.map { detail_hash(_1) },
        }
      end

    private

      def detail_hash(pt_detail)
        {
          ccms_code: pt_detail[:ccms_code],
          matter_type: matter_type(pt_detail),
          gross_income_upper: waived?(pt_detail),
          disposable_income_upper: waived?(pt_detail),
          capital_upper: waived?(pt_detail),
          client_involvement_type: pt_detail[:client_involvement_type],
        }
      end

      def matter_type(pt_detail)
        case pt_detail[:ccms_code]
        when /^DA/
          "Domestic abuse"
        when /^SE/
          "Children - section 8"
        else
          raise "Unrecognised CCMS code: #{pt_detail[:ccms_code]}"
        end
      end

      def waived?(pt_detail)
        matter_type(pt_detail) == "Domestic abuse" && pt_detail[:client_involvement_type] == "A" ? true : false
      end
    end
  end
end
