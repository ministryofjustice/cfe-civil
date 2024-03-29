module Calculators
  class StatePensionDateCalculator
    class << self
      AGE = "age".freeze
      FIXED = "fixed".freeze
      FAR_FLUNG_FUTURE_DATE = "2999-12-31".freeze

      # Calculates the date on which a UK citizen becomes eligible for their State Pension.
      def state_pension_date(date_of_birth:)
        pension_rule = PENSION_TABLE.detect do |rule|
          start_date = Date.parse(rule[:periodStart])
          end_date = Date.parse(rule.fetch(:periodEnd, FAR_FLUNG_FUTURE_DATE))
          date_of_birth.between?(start_date, end_date)
        end
        # We must be before the start of the table
        if pension_rule.present?
          data = pension_rule[:pensionDate]
          send("#{data[:type]}_pension_date", date_of_birth, data)
        else
          #  This person is a pensioner so any value will do
          date_of_birth + 60.years
        end
      end

    private

      def fixed_pension_date(_date_of_birth, data)
        Date.parse(data[:value])
      end

      def age_pension_date(date_of_birth, data)
        (date_of_birth + data[:years].years + data[:months].months)
      end

      # https://github.com/dwp/get-state-pension-date/blob/master/src/spa-data.js
      PENSION_TABLE =
        [
          {
            periodStart: "1953-12-06",
            periodEnd: "1954-01-05",
            pensionDate: {
              type: FIXED,
              value: "2019-03-06",
            },
          },
          {
            periodStart: "1954-01-06",
            periodEnd: "1954-02-05",
            pensionDate: {
              type: FIXED,
              value: "2019-05-06",
            },
          },
          {
            periodStart: "1954-02-06",
            periodEnd: "1954-03-05",
            pensionDate: {
              type: FIXED,
              value: "2019-07-06",
            },
          },
          {
            periodStart: "1954-03-06",
            periodEnd: "1954-04-05",
            pensionDate: {
              type: FIXED,
              value: "2019-09-06",
            },
          },
          {
            periodStart: "1954-04-06",
            periodEnd: "1954-05-05",
            pensionDate: {
              type: FIXED,
              value: "2019-11-06",
            },
          },
          {
            periodStart: "1954-05-06",
            periodEnd: "1954-06-05",
            pensionDate: {
              type: FIXED,
              value: "2020-01-06",
            },
          },
          {
            periodStart: "1954-06-06",
            periodEnd: "1954-07-05",
            pensionDate: {
              type: FIXED,
              value: "2020-03-06",
            },
          },
          {
            periodStart: "1954-07-06",
            periodEnd: "1954-08-05",
            pensionDate: {
              type: FIXED,
              value: "2020-05-06",
            },
          },
          {
            periodStart: "1954-08-06",
            periodEnd: "1954-09-05",
            pensionDate: {
              type: FIXED,
              value: "2020-07-06",
            },
          },
          {
            periodStart: "1954-09-06",
            periodEnd: "1954-10-05",
            pensionDate: {
              type: FIXED,
              value: "2020-09-06",
            },
          },
          {
            periodStart: "1954-10-06",
            periodEnd: "1960-04-05",
            pensionDate: {
              type: AGE,
              years: 66,
              months: 0,
            },
          },
          # Increase in State Pension age from 66 to 67, men and women
          {
            periodStart: "1960-04-06",
            periodEnd: "1960-05-05",
            pensionDate: {
              type: AGE,
              years: 66,
              months: 1,
            },
          },
          {
            periodStart: "1960-05-06",
            periodEnd: "1960-06-05",
            pensionDate: {
              type: AGE,
              years: 66,
              months: 2,
            },
          },
          {
            periodStart: "1960-06-06",
            periodEnd: "1960-07-05",
            pensionDate: {
              type: AGE,
              years: 66,
              months: 3,
            },
          },
          {
            periodStart: "1960-07-06",
            periodEnd: "1960-08-05",
            pensionDate: {
              type: AGE,
              years: 66,
              months: 4,
            },
          },
          {
            periodStart: "1960-08-06",
            periodEnd: "1960-09-05",
            pensionDate: {
              type: AGE,
              years: 66,
              months: 5,
            },
          },
          {
            periodStart: "1960-09-06",
            periodEnd: "1960-10-05",
            pensionDate: {
              type: AGE,
              years: 66,
              months: 6,
            },
          },
          {
            periodStart: "1960-10-06",
            periodEnd: "1960-11-05",
            pensionDate: {
              type: AGE,
              years: 66,
              months: 7,
            },
          },
          {
            periodStart: "1960-11-06",
            periodEnd: "1960-12-05",
            pensionDate: {
              type: AGE,
              years: 66,
              months: 8,
            },
          },
          {
            periodStart: "1960-12-06",
            periodEnd: "1961-01-05",
            pensionDate: {
              type: AGE,
              years: 66,
              months: 9,
            },
          },
          {
            periodStart: "1961-01-06",
            periodEnd: "1961-02-05",
            pensionDate: {
              type: AGE,
              years: 66,
              months: 10,
            },
          },
          {
            periodStart: "1961-02-06",
            periodEnd: "1961-03-05",
            pensionDate: {
              type: AGE,
              years: 66,
              months: 11,
            },
          },
          {
            periodStart: "1961-03-06",
            periodEnd: "1977-04-05",
            pensionDate: {
              type: AGE,
              years: 67,
              months: 0,
            },
          },
          # Increase in State Pension age from 67 to 68 under the Pensions Act 2007
          {
            periodStart: "1977-04-06",
            periodEnd: "1977-05-05",
            pensionDate: {
              type: FIXED,
              value: "2044-05-06",
            },
          },
          {
            periodStart: "1977-05-06",
            periodEnd: "1977-06-05",
            pensionDate: {
              type: FIXED,
              value: "2044-07-06",
            },
          },
          {
            periodStart: "1977-06-06",
            periodEnd: "1977-07-05",
            pensionDate: {
              type: FIXED,
              value: "2044-09-06",
            },
          },
          {
            periodStart: "1977-07-06",
            periodEnd: "1977-08-05",
            pensionDate: {
              type: FIXED,
              value: "2044-11-06",
            },
          },
          {
            periodStart: "1977-08-06",
            periodEnd: "1977-09-05",
            pensionDate: {
              type: FIXED,
              value: "2045-01-06",
            },
          },
          {
            periodStart: "1977-09-06",
            periodEnd: "1977-10-05",
            pensionDate: {
              type: FIXED,
              value: "2045-03-06",
            },
          },
          {
            periodStart: "1977-10-06",
            periodEnd: "1977-11-05",
            pensionDate: {
              type: FIXED,
              value: "2045-05-06",
            },
          },
          {
            periodStart: "1977-11-06",
            periodEnd: "1977-12-05",
            pensionDate: {
              type: FIXED,
              value: "2045-07-06",
            },
          },
          {
            periodStart: "1977-12-06",
            periodEnd: "1978-01-05",
            pensionDate: {
              type: FIXED,
              value: "2045-09-06",
            },
          },
          {
            periodStart: "1978-01-06",
            periodEnd: "1978-02-05",
            pensionDate: {
              type: FIXED,
              value: "2045-11-06",
            },
          },
          {
            periodStart: "1978-02-06",
            periodEnd: "1978-03-05",
            pensionDate: {
              type: FIXED,
              value: "2046-01-06",
            },
          },
          {
            periodStart: "1978-03-06",
            periodEnd: "1978-04-05",
            pensionDate: {
              type: FIXED,
              value: "2046-03-06",
            },
          },
          {
            periodStart: "1978-04-06",
            pensionDate: {
              type: AGE,
              years: 68,
              months: 0,
            },
          },
        ].freeze
    end
  end
end
