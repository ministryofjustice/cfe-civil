ExplicitRemark = Data.define :category, :remark do
  def self.by_category(remarks)
    remarks.sort_by { |r| [r.category, r.remark] }
           .group_by(&:category)
           .transform_values { |xr| xr.map(&:remark) }
           .symbolize_keys
  end
end
