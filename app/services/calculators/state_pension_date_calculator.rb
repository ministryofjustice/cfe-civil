module Calculators
  class StatePensionDateCalculator
    class << self
      AGE = "age".freeze
      FIXED = "fixed".freeze

      # Calculates the date on which a UK citizen becomes eligible for their State Pension.
      def state_pension_date(date_of_birth:)
        date_of_birth = Date.parse(date_of_birth)
        pension_table.detect do |obj|
          start_date = Date.parse(obj[:periodStart])
          if start_date >= Date.parse("1978-04-06")
            # After 6th April 1978 then pension age is 68.
            return (date_of_birth + obj[:pensionDate][:years].years + obj[:pensionDate][:months].months).to_s
          else
            end_date = Date.parse(obj[:periodEnd])
            if date_of_birth.between?(start_date, end_date)
              if obj[:pensionDate][:type] == FIXED
                return obj[:pensionDate][:value]
              elsif obj[:pensionDate][:type] == AGE
                return (date_of_birth + obj[:pensionDate][:years].years + obj[:pensionDate][:months].months).to_s
              end
            end
          end
        end
      end

    private

      # https://github.com/dwp/get-state-pension-date/blob/master/src/spa-data.js
      def pension_table
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
        ]
      end
    end
  end
end
