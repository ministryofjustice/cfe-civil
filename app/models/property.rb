Property = Data.define(:value, :outstanding_mortgage, :percentage_owned, :main_home, :shared_with_housing_assoc, :subject_matter_of_dispute) do
  def self.blank_main_home
    new(main_home: true, value: 0, outstanding_mortgage: 0, percentage_owned: 0, shared_with_housing_assoc: false, subject_matter_of_dispute: false)
  end
end
