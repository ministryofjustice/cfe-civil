class Threshold
  def initialize(data_folder_path = "config/thresholds")
    @threshold_data = load_data data_folder_path
  end

  def value_for(item, at:)
    key = threshold_data.keys.select { |time| time <= at }.max || threshold_data.keys.min
    threshold = threshold_data[key]
    threshold[item.to_sym]
  end

private

  attr_reader :threshold_data

  def load_data(data_folder_path)
    index = YAML.safe_load_file(Rails.root.join(data_folder_path, "values.yml"), permitted_classes: [Date])
    data = index.map do |date, filename|
      hash = YAML.safe_load_file(Rails.root.join(filename), permitted_classes: [Date]).deep_symbolize_keys
      if Rails.configuration.x.future_test_data_file == filename.split("/").last
        [Time.zone.today, hash]
      else
        [date.beginning_of_day, hash]
      end
    end
    data.select { |_date, hash| threshold_loadable?(hash) }.to_h
  end

  def threshold_loadable?(hash)
    return true unless hash.key?(:test_only)

    Rails.configuration.x.use_test_threshold_data == "true"
  end

  class << self
    def value_for(item, at:)
      threshold.value_for(item, at:)
    end

  private

    def threshold
      @threshold ||= Threshold.new
    end
  end
end
