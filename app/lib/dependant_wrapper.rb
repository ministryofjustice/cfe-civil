# This is an adapter for the 'dependant' model so that we can ask questions about their age.
# All calculations are done off 'submission_date' rather than 'today', so it has to be passed into the constructor
class DependantWrapper
  delegate :assets_value, :dependant_allowance, :monthly_income, :asset_value, :update!, to: :@dependant

  def initialize(dependant:, submission_date:)
    @dependant = dependant
    @submission_date = submission_date
  end

  def under_15_years_old?
    @dependant.date_of_birth > (@submission_date - 15.years)
  end

  def under_16_years_old?
    @dependant.date_of_birth > (@submission_date - 16.years)
  end

  def under_18_in_full_time_education?
    @dependant.date_of_birth > (@submission_date - 18.years) && @dependant.in_full_time_education?
  end
end
