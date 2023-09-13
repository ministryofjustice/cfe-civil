module Calculators
  class PensionerCapitalDisregardCalculator
    DOB_TO_PENSION_AGE_2014 = {
      Date.new(1954, 10, 6) => 66.years,
      Date.new(1960, 4, 5) => 66.years + 1.month,
    }.freeze

    DOB_TO_PENSION_DATE_2007 = {
      Date.new(1977, 4, 6) => Date.new(2044, 5, 5),
      Date.new(1977, 5, 6) => Date.new(2044, 7, 6),
    }.freeze

    def initialize(submission_date:, date_of_birth:, total_disposable_income:, receives_qualifying_benefit:)
      @submission_date = submission_date
      @date_of_birth = date_of_birth
      @total_disposable_income = total_disposable_income
      @receives_qualifying_benefit = receives_qualifying_benefit
    end

    def value
      return 0 unless pensioner?

      passported? ? passported_value : non_passported_value
    end

    def thresholds
      @thresholds ||= Threshold.value_for(:pensioner_capital_disregard, at: @submission_date)
    end

  private

    def pensioner?
      if thresholds[:minimum_age_in_years] == "state_pension_age"
        if dob >= DOB_TO_PENSION_AGE_2014.keys.first && dob < DOB_TO_PENSION_AGE_2014.keys.last
          target_key = DOB_TO_PENSION_AGE_2014.keys.each_cons(2).find { |lower, upper| lower <= dob && dob < upper }
          pension_age = DOB_TO_PENSION_AGE_2014.fetch(target_key)
          @submission_date >= (dob + pension_age)
        end
      elsif dob >= DOB_TO_PENSION_DATE_2007.first && dob < DOB_TO_PENSION_DATE_2007.last
        earliest_dob_for_pensioner >= person_dob
      elsif dob >= Date.new(1978, 4, 6)
        #  After 6th April 1978 then pension age is 68.
        @submission_date >= dob + 68
      else
        true
      end
    end

    def earliest_dob_for_pensioner
      @submission_date - thresholds[:minimum_age_in_years].years
    end

    def person_dob
      @date_of_birth
    end

    def passported?
      @receives_qualifying_benefit
    end

    def non_passported_value
      income = @total_disposable_income.to_f
      thresholds[:monthly_income_values].each { |value_bands, banding| return banding if income_threshold_applies(income, value_bands) }
    end

    def passported_value
      thresholds[:non_passported]
    end

    def income_threshold_applies(income, key_array)
      (key_array.count.eql?(1) && income >= key_array[0]) || (income >= key_array[0] && income <= key_array[1])
    end
  end
end
