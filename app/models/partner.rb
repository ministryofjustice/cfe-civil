class Partner < ApplicationRecord
  belongs_to :assessment, optional: true
  validates :assessment_id, uniqueness: { message: "There is already a partner for this assesssment" }

  validates :date_of_birth, date: {
    before: proc { Time.zone.tomorrow }, message: :not_in_the_future
  }
end
