module TestCase
  module V5
    class RemarksComparer
      def self.call(expected, actual, verbosity)
        new(expected, actual, verbosity).call
      end

      def initialize(expected, actual, verbosity)
        @expected = expected
        @actual = actual
        @verbosity = verbosity
      end

      def call
        print_actual_remarks unless silent?

        return [] if @expected.blank?

        compare_remarks
      end

      def silent?
        @verbosity.zero?
      end

      def compare_remarks
        puts "Remarks >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>".green unless silent?

        @expected.flat_map { |remark_type, remark_type_hash| compare_remark_type(remark_type, remark_type_hash) }
      end

      def compare_remark_type(type, hash)
        hash.keys.map do |issue|
          actual_unsorted_remarks = @actual&.dig(type)&.dig(issue)
          actual_remarks = actual_unsorted_remarks.nil? ? nil : actual_unsorted_remarks.sort
          { name: "remark_#{type}_#{issue}", actual: actual_remarks, expected: @expected[type][issue].sort }
        end
      end

      def print_remark_line(type, issue)
        color = :red
        puts "#{type}/#{issue}".__send__(color)
        puts "  expected:"
        @expected[type][issue].each { |id| puts "    #{id}" }
        puts "  actual:"
        @actual&.dig(type)&.dig(issue)&.each { |id| puts "    #{id}" }
        puts "  "
      end

      def print_actual_remarks
        puts "Actual remaks returned from CFE >>>>>>>>>>>>>>>>>>>>>>>>>".blue
        @actual.each do |type, issue|
          puts "#{type}:".blue
          issue.each do |issue_name, ids|
            puts "  #{issue_name}:".blue
            ids.each { |id| puts "    #{id}".blue }
          end
        end
      end

      def verbose(string, color = :green)
        puts string.__send__(color) unless silent?
        @result = false if color == :red
      end
    end
  end
end
