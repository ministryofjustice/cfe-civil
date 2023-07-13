# used to convert DB layer into domain layer for rules
class PersonWrapper
  attr_reader :dependants

  def initialize(is_single:, person_data:)
    @is_single = is_single
    @dependants = person_data.dependants
  end

  def single?
    @is_single
  end
end
