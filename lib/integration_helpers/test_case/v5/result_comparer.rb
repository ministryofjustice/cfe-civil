require_relative "remarks_comparer"

module TestCase
  module V5
    class ResultComparer
      def self.call(actual, expected, verbosity)
        new(actual, expected, verbosity).call
      end

      def initialize(actual, expected, verbosity)
        @actual = actual
        @expected = expected
        @verbosity = verbosity
      end

      attr_reader :expected, :actual, :verbosity

      HEADER_PATTERN = "%58s  %-26s %-s".freeze

      def call
        print_headings
        COMPARISONS.flat_map { |comp| comp.call(self) }.reject { |item| item.fetch(:expected).nil? }
      end

      GROSS_COMPARABLES = {
        monthly_other_income: ->(o) { { actual: o.actual_gross_other_income, expected: o.expected_gi_other_income } },
        monthly_state_benefits: ->(o) { { actual: o.actual_gross_state_benefits, expected: o.expected_gi_state_benefits } },
        monthly_student_loan: ->(o) { { actual: o.actual_student_loan, expected: o.expected_gi_student_loan } },
        employment_income_gross: ->(o) { { actual: o.actual_employment_income[:gross_income], expected: o.expected_employment_income_gross } },
        employment_income_benefits_in_kind: ->(o) { { actual: o.actual_employment_income[:benefits_in_kind], expected: o.expected_employment_income_benefits_in_kind } },
        employment_income_tax: ->(o) { { actual: o.actual_employment_income[:tax], expected: o.expected_employment_income_tax } },
        employment_income_nic: ->(o) { { actual: o.actual_employment_income[:national_insurance], expected: o.expected_employment_income_nic } },
        fixed_employment_allowance: ->(o) { { actual: o.actual_employment_income[:fixed_employment_deduction], expected: o.expected_fixed_employment_allowance } },
        total_gross_income: ->(o) { { actual: o.actual_total_gross_income, expected: o.expected_total_gross_income } },
      }.freeze

      DISPOSABLE_COMPARABLES = {
        childcare: ->(o) { { actual: o.actual_disposable(:child_care), expected: o.expected_disposable(:childcare) } },
        dependant_allowance: ->(o) { { actual: o.actual_dependant_allowance, expected: o.expected_disposable(:dependant_allowance) } },
        legal_aid: ->(o) { { actual: o.actual_disposable(:legal_aid), expected: o.expected_disposable(:legal_aid) } },
        maintenance: ->(o) { { actual: o.actual_disposable(:maintenance_out), expected: o.expected_disposable(:maintenance) } },
        gross_housing_costs: ->(o) { { actual: o.disposable_income_result[:gross_housing_costs], expected: o.expected_disposable(:gross_housing_costs) } },
        housing_benefit: ->(o) { { actual: o.disposable_income_result[:housing_benefit], expected: o.expected_disposable(:housing_benefit) } },
        net_housing_costs: ->(o) { { actual: o.disposable_income_result[:net_housing_costs], expected: o.expected_disposable(:net_housing_costs) } },
        total_outgoings_and_allowances: ->(o) { { actual: o.disposable_income_result[:total_outgoings_and_allowances], expected: o.expected_disposable(:total_outgoings_and_allowances) } },
        total_disposable_income: ->(o) { { actual: o.disposable_income_result[:total_disposable_income], expected: o.expected_disposable(:total_disposable_income) } },
        income_contribution: ->(o) { { actual: o.disposable_income_result[:income_contribution], expected: o.expected_disposable(:income_contribution) } },
      }.freeze

      COMPARISONS = [
        lambda { |o|
          [{ name: "assessment_result", actual: o.actual_overall_result[:result], expected: o.expected_assessment[:assessment_result] }]
        },
        lambda { |o|
          if o.actual_proceeding_type_codes == o.expected_proceeding_type_codes
            o.expected_proceeding_types
              .flat_map do |code, expected_result_hash|
                o.verbose "Proceeding_type #{code}", :green
                PROCEEDING_TYPE_COMPARISONS.map do |name, method|
                  exp_act = method.call(o, code, expected_result_hash)
                  # o.compare_and_print("Proceeding_type #{code} #{name}", exp_act.fetch(:actual), exp_act.fetch(:expected))
                  exp_act.merge(name: "Proceeding_type #{code} #{name}")
                end
              end
          else
            [{ name: "proceeding_type_codes", actual: actual_proceeding_type_codes.join(", "), expected: expected_proceeding_type_codes.join(", ") }]
          end
        },
        lambda { |o|
          o.verbose "Gross income >>>>>>>>>>>>>>>>>>>>>>>>>", :green
          GROSS_COMPARABLES.map do |name, method|
            exp_act = method.call(o)
            exp_act.merge(name: name.to_s)
          end
        },
        lambda { |o|
          o.verbose "Disposable income >>>>>>>>>>>>>>>>>>>>>>", :green
          DISPOSABLE_COMPARABLES.map do |name, method|
            exp_act = method.call(o)
            exp_act.merge(name: name.to_s)
          end
        },
        lambda { |o|
          o.verbose "Capital >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", :green
          o.expected_capital.map do |key, value|
            { name: key, actual: o.actual_capital[key], expected: value }
          end
        },
        lambda { |o|
          RemarksComparer.call(o.expected[:remarks], o.actual[:assessment][:remarks], o.verbosity)
        },
      ].freeze

      def silent?
        @verbosity.zero?
      end

      def print_headings
        verbose sprintf(HEADER_PATTERN, client_reference_id, "Expected", "Actual")
        verbose sprintf(HEADER_PATTERN, "", "=========", "=========")
      end

      def print_mismatched_proceeding_type_codes
        verbose "Proceeding type codes do not match expected", :red
        verbose "  Expected: #{expected_proceeding_type_codes.join(', ')}", :red
        verbose "  Actual  : #{actual_proceeding_type_codes.join(', ')}", :red
      end

      def client_reference_id
        @actual[:assessment][:client_reference_id]
      end

      PROCEEDING_TYPE_COMPARISONS = {
        result: ->(o, code, expected_result_hash) { { actual: o.actual_proceeding_type_result(code), expected: expected_result_hash[:result] } },
        capital_lower_threshold: ->(o, code, expected_result_hash) { { actual: o.actual_cap_result_for(code)[:lower_threshold], expected: expected_result_hash[:capital_lower_threshold] } },
        capital_upper_threshold: ->(o, code, expected_result_hash) { { actual: o.actual_cap_result_for(code)[:upper_threshold], expected: expected_result_hash[:capital_upper_threshold] } },
        gross_income_upper_threshold: ->(o, code, expected_result_hash) { { actual: o.actual_gross_income_result_for(code)[:upper_threshold], expected: expected_result_hash[:gross_income_upper_threshold] } },
        disposable_income_lower_threshold: lambda { |o, code, expected_result_hash|
                                             { actual: o.actual_disposable_income_result_for(code)[:lower_threshold],
                                               expected: expected_result_hash[:disposable_income_lower_threshold] }
                                           },
        disposable_income_upper_threshold: lambda { |o, code, expected_result_hash|
                                             { actual: o.actual_disposable_income_result_for(code)[:upper_threshold],
                                               expected: expected_result_hash[:disposable_income_upper_threshold] }
                                           },

      }.freeze

      def compare_and_print(legend, actual, expected)
        color = if expected.nil?
                  :blue
                elsif actual.to_s != expected.to_s
                  :red
                else
                  :green
                end
        verbose sprintf(HEADER_PATTERN, legend, expected, actual), color
        color != :red
      end

      def verbose(string, color = :green)
        puts string.__send__(color) unless silent?
      end

      def actual_result_summary
        @actual[:result_summary]
      end

      def actual_overall_result
        actual_result_summary[:overall_result]
      end

      def actual_matter_types
        actual_overall_result[:matter_types]
      end

      def actual_matter_type_names
        actual_matter_types.pluck(:matter_type).sort
      end

      def actual_matter_type_result_for(matter_type_name)
        hash = actual_matter_types.detect { |h| h[:matter_type] == matter_type_name.to_s }
        hash[:result]
      end

      def actual_proceeding_types
        actual_overall_result[:proceeding_types]
      end

      def actual_proceeding_type_codes
        actual_proceeding_types.map { |h| h.fetch(:ccms_code) }.sort
      end

      def actual_proceeding_type_result(code)
        actual_proceeding_types.detect { |h| h[:ccms_code] == code }[:result]
      end

      def actual_cap_result
        @actual[:result_summary][:capital]
      end

      def actual_cap_proceeding_types
        actual_cap_result[:proceeding_types]
      end

      def actual_cap_result_for(code)
        actual_cap_proceeding_types.detect { |h| h[:ccms_code] == code }
      end

      def actual_gross_income_result
        @actual[:result_summary][:gross_income]
      end

      def actual_gross_income_proceeding_types
        actual_gross_income_result[:proceeding_types]
      end

      def actual_gross_income_result_for(code)
        actual_gross_income_proceeding_types.detect { |h| h[:ccms_code] == code }
      end

      def actual_disposable_income_result
        @actual[:result_summary][:disposable_income]
      end

      def actual_disposable_income_proceeding_types
        actual_disposable_income_result[:proceeding_types]
      end

      def actual_disposable_income_result_for(code)
        actual_disposable_income_proceeding_types.detect { |h| h[:ccms_code] == code }
      end

      def actual_gross_income
        @actual[:assessment][:gross_income]
      end

      def actual_gross_other_income
        actual_gross_income[:other_income][:monthly_equivalents][:all_sources].values.sum(&:to_f)
      end

      def actual_gross_state_benefits
        actual_gross_income[:state_benefits][:monthly_equivalents][:all_sources]
      end

      def actual_student_loan
        actual_gross_income[:irregular_income][:monthly_equivalents][:student_loan]
      end

      def actual_total_gross_income
        actual_result_summary[:gross_income][:total_gross_income]
      end

      def actual_disposable_income
        @actual[:assessment][:disposable_income]
      end

      def actual_disposable(key)
        actual_disposable_income[:monthly_equivalents][:all_sources][key]
      end

      def actual_dependant_allowance
        actual_disposable_income[:deductions][:dependants_allowance]
      end

      def disposable_income_result
        @actual[:result_summary][:disposable_income]
      end

      def actual_housing_benefit
        disposable_income_result[:housing_benefit]
      end

      def actual_net_housing_costs
        disposable_income_result[:net_housing_costs]
      end

      def actual_capital
        @actual[:result_summary][:capital]
      end

      def actual_employment_income
        disposable_income_result[:employment_income]
      end

      def expected_assessment
        @expected[:assessment]
      end

      def expected_matter_types
        expected_assessment[:matter_types]
      end

      def expected_matter_type_names
        @expected[:assessment][:matter_types].map(&:keys).flatten.sort.map(&:to_s)
      end

      def expected_proceeding_types
        expected_assessment[:proceeding_types]
      end

      def expected_proceeding_type_codes
        expected_proceeding_types.keys.sort
      end

      def expected_gross_income
        @expected[:gross_income_summary]
      end

      def expected_gi_other_income
        expected_gross_income[:monthly_other_income]
      end

      def expected_gi_state_benefits
        expected_gross_income[:monthly_state_benefits]
      end

      def expected_gi_student_loan
        expected_gross_income[:monthly_student_loan]
      end

      def expected_total_gross_income
        expected_gross_income[:total_gross_income]
      end

      def expected_disposable_income
        @expected[:disposable_income_summary]
      end

      def expected_disposable(key)
        expected_disposable_income[key]
      end

      def expected_capital
        @expected[:capital]
      end

      def expected_employment_income_gross
        expected_gross_income[:employment_income_gross]
      end

      def expected_employment_income_benefits_in_kind
        expected_gross_income[:employment_income_benefits_in_kind]
      end

      def expected_employment_income_tax
        expected_gross_income[:employment_income_tax]
      end

      def expected_employment_income_nic
        expected_gross_income[:employment_income_nic]
      end

      def expected_fixed_employment_allowance
        expected_gross_income[:fixed_employment_allowance]
      end
    end
  end
end
