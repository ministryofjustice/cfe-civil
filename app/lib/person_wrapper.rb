# used to convert DB layer into domain layer for rules
class PersonWrapper
  attr_reader :dependants

  def initialize(is_single:, dependants:)
    @is_single = is_single
    @dependants = dependants
  end

  def single?
    @is_single
  end
end
