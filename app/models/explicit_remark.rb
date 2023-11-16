class ExplicitRemark < ApplicationRecord
  belongs_to :assessment

  validates :category, inclusion: { in: CFEConstants::VALID_REMARK_CATEGORIES,
                                    message: "%<value>s is not a valid remark category" }

  scope :by_category, lambda {
    order(:category, :remark)
    .pluck(:category, :remark)
    .group_by(&:first)
    .transform_values { |xr| xr.map(&:last) }
    .symbolize_keys
  }
end
